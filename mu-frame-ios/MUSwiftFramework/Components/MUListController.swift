//
//  ObjectTableController.swift

//
//  Created by Dmitry Smirnov on 28.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MUListControlDelegate

@objc protocol MUListControlDelegate: class {
    
    func cellIdentifier(for object: MUModel, at indexPath: IndexPath) -> String?
    
    func cellIdentifier(at indexPath: IndexPath) -> String?
    
    func cellDidSelected(for object: MUModel)
    
    func getSection(for object: MUModel) -> String?
    
    func isObjectChanged(for object: MUModel) -> Bool
    
    func objectDidChanged(with objects: [MUModel])
    
    func scrollDidScroll(_ scrollView: UIScrollView)
    
    // MARK: - UITableViewDataSource
    
    @objc optional func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    
    @objc optional func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    
    // MARK: - UITableViewDelegate
    
    @objc optional func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    
    @objc optional func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    
    // MARK: - UICollectionViewDataSource
    
    @objc optional func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    
    @objc optional func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int) -> CGFloat
    
    // MARK: - UICollectionViewDelegate
    
    @objc optional func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
}

// MARK: - MUListController

class MUListController: MUViewController, MUListControlDelegate {
    
    // MARK: - Public properties
    
    var hasRefresh: Bool { return false }
    
    var hasPagination: Bool { return false }
    
    var hasEmptyState: Bool { return false }
    
    var hasCache: Bool { return false }
    
    @IBOutlet weak var tableView: UITableView?
    
    @IBOutlet weak var collectionView: UICollectionView?
    
    @IBOutlet weak var emptyView: UIView? { didSet { emptyStateControl.emptyView = emptyView } }
    
    var objects: [MUModel] {
        
        set { setObjects(with: newValue)  }
        get { return getObjects() }
    }
    
    // MARK: - Controls
    
    var tableControl = MUTableControl()
    
    var collectionControl = MUCollectionControl()
    
    var emptyStateControl = MUEmptyStateControl()
    
    var refreshControl = MURefreshControl()
    
    var paginationControl = MUPaginationControl()
    
    var cacheControl: MUCacheControlProtocol? { return nil }
    
    // MARK: - Private properties
    
    private var activityTimer: Timer?
    
    // MARK: - Override methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        cacheControl?.setup(with: self)
        
        tableControl.setup(with: self)
        
        collectionControl.setup(with: self)
        
        paginationControl.setup(with: self)
        
        refreshControl.setup(with: self)
        
        emptyStateControl.setup(with: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        emptyStateControl.updateLayout()
    }
    
    override func appErrorDidBecome(error: Error) {
        
        super.appErrorDidBecome(error: error)
        
        paginationControl.cancelLastPage()
        
        hideActivityIndicators(withDelay: 0.3)
    }
    
    // MARK: - Public methods
    
    @objc func hideActivityIndicators() {
        
        hideActivityIndicator()
        
        refreshControl.stopAnimation()
        
        emptyStateControl.stopAnimation()
        
        paginationControl.stopAnimation()
    }
    
    func hideActivityIndicators(withDelay delay: TimeInterval) {
        
        activityTimer?.invalidate()
        
        activityTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(hideActivityIndicators as () -> ()), userInfo: nil, repeats: false)
    }
    
    // MARK: - Request
    
    func beginRequest() {
        
        update(objects: [])
    }
    
    func update(objects newObjects: [MUModel]) {
        
        if refreshControl.isRefreshing {
            
            updateWithTimeInterval(objects: newObjects)
        } else {
            updateWithoutTimeInterval(objects: newObjects)
        }
        
        hideActivityIndicators()
    }
    
    func updateWithTimeInterval(objects newObjects: [MUModel], interval: Double = 0.1) {
        
        Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(updateIfNeeded(_:)), userInfo: ["newObjects": newObjects], repeats: true)
    }
    
    func updateWithoutTimeInterval(objects newObjects: [MUModel]) {
        
        if paginationControl.page > 1 {
            
            objects += newObjects
        } else {
            objects = newObjects
        }
    }
    
    func requestObjects(withIndicator: Bool = true) {
        
        if withIndicator {
            
            showActivityIndicator()
        }
        
        beginRequest()
    }
    
    // MARK: - Private methods
    
    @objc private func updateIfNeeded(_ timer: Timer) {
        
        guard !refreshControl.isRefreshing, tableView?.contentOffset.y ?? 0 == 0 else { return }
        
        if let userInfo = timer.userInfo as? [String: [MUModel]], let newObjects = userInfo["newObjects"] {
            
            updateWithoutTimeInterval(objects: newObjects)
        }
        
        timer.invalidate()
    }
    
    private func getObjects() -> [MUModel] {
        
        if tableView != nil {
            
            return tableControl.objects
        } else {
            return collectionControl.objects
        }
    }
    
    private func setObjects(with newObjects: [MUModel]) {
        
        if tableView != nil {
            
            tableControl.objects = newObjects
        } else {
            collectionControl.objects = newObjects
        }
    }

    // MARK: - MUListControlDelegate
    
    func cellIdentifier(for object: MUModel, at indexPath: IndexPath) -> String? {
        
        return "Cell"
    }
    
    func cellIdentifier(at indexPath: IndexPath) -> String? {
        
        return nil
    }
    
    func cellDidSelected(for object: MUModel) {
        
    }
    
    func getSection(for object: MUModel) -> String? {
        
        return ""
    }
    
    func isObjectChanged(for object: MUModel) -> Bool {
        
        return false
    }
    
    func objectDidChanged(with objects: [MUModel]) {
        
    }
    
    func scrollDidScroll(_ scrollView: UIScrollView) {
        
        paginationControl.scroll(with: scrollView)
    }
}

// MARK: - MURefreshControlDelegate

extension MUListController: MURefreshControlDelegate {
    
    func refreshControlDidRefresh() {
        
        paginationControl.reset()
        
        requestObjects(withIndicator: false)
    }
}

// MARK: - MUPaginationControlDelegate

extension MUListController: MUPaginationControlDelegate {
    
    func paginationControlDidRequestMore(page: Int) {
        
        requestObjects(withIndicator: false)
    }
}
