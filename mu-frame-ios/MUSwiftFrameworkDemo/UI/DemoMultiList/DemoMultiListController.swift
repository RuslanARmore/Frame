//
//  DemoMultiListController.swift
//  MUSwiftFramework
//
//  Created by Dmitry Smirnov on 06/03/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

class DemoMultiListController: ListController {
    
    // MARK: - Override properties
    
    override var hasRefresh: Bool { return true }
    
    override var hasPagination: Bool { return true }
    
    override var hasCache: Bool { return true }
    
    override var cacheControl: MUCacheControlProtocol? { return DemoObject.cacheControl }
    
    override var behaviors: BehaviorOptions { return BehaviorPreset.defaultTab }
    
    // MARK: - Private properties
    
    @IBOutlet private weak var tableProvider: UITableView! { didSet { tableView = tableProvider } }
    
    // MARK: - Override methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableControl.reservePosition(at: 1, forCell: "InvitationCell")
    }
    
    override func beginRequest() {
        
        guard isFirstAppear || paginationControl.page > 1 else { return hideActivityIndicators() }
        
        DemoService.getAll(delay: 0.2) { [weak self] (objects) in
            
            self?.update(objects: objects)
        }
    }
}

// MARK: - DemoInvitationCell

class DemoInvitationCell: MUTableCell {
    
    // MARK: - Private properties
    
    private weak var controller: DemoMultiListController?
    
    // MARK: - Override methods
    
    override func setup(sender: Any?) {
        
        controller = sender as? DemoMultiListController
    }
    
    // MARK: - Private methods
    
    @IBAction private func buttonTap(_ sender: Any) {
        
        DemoFormController.push(to: controller)
    }
}

// MARK: - DemoMultiCell

class DemoMultiCell: MUTableCell {
    
    // MARK: - Private properties
    
    private weak var tableController: DemoMultiListController?
    
    private weak var cellController: DemoMultiListFirstChildController?
    
    @IBOutlet private weak var containerView: View!
    
    // MARK: - Override methods
    
    override func setup(with object: MUModel, sender: Any?) {
        
        super.setup(with: object)
        
        guard let object = object as? DemoObject, let tableController = sender as? DemoMultiListController else { return }
        
        self.tableController = tableController
        
        switch object.type ?? .first {
        case .first  : updateController(with: DemoMultiListFirstChildController.self, into: containerView)
        case .second : updateController(with: DemoMultiListSecondChildController.self, into: containerView)
        case .third  : updateController(with: DemoMultiListThirdChildController.self, into: containerView)
        }
    }
    
    // MARK: - Private methods
    
    private func updateController<T: DemoMultiListFirstChildController>(with controller: T.Type, into view: View) {
        
        cellController?.removeFromParent()
        
        cellController = nil
        
        containerView.removeAllSubviews()
        
        tableController?.insert(controller : T.self, into : containerView) { [weak self] (instance: DemoMultiListFirstChildController) in
            
            self?.cellController = instance
            
            instance.object = self?.object as? DemoObject
            
            instance.cacheControl?.setCacheKey(with: "DemoMultiList_\(self?.object?.primaryKey ?? "")")
        }
    }
}

// MARK: - DemoMultiListFirstChildController

class DemoMultiListFirstChildController: ListController {
    
    override class var storyboardName: String { return "DemoMultiList" }
    
    // MARK: - Public properties
    
    weak var object: DemoObject?
    
    // MARK: - Override properties
    
    override var hasCache: Bool { return true }
    
    override var cacheControl: MUCacheControlProtocol? { return cacheControlProvider }
    
    override var behaviors: BehaviorOptions { return BehaviorPreset.dataOnly }
    
    // MARK: - Private properties
    
    private var cacheControlProvider = MUCacheControl<DemoObject>()
    
    @IBOutlet private weak var errorView: UIView!
    
    @IBOutlet private weak var collectionProvider: UICollectionView! { didSet { collectionView = collectionProvider } }
    
    private static var contentOffsetArray: [String: CGFloat] = [:]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        indicatorControl.style = .dark
        
        indicatorControl.defaultDelay = 0.1
        
        loadContentOffset()
    }
    
    override func appErrorDidBecome(error: Error) {
        
        collectionView?.alpha = 0
    }
    
    // MARK: - Override methods
    
    override func beginRequest() {
        
        collectionView?.alpha = 1
        
        guard objects.isEmpty else { return hideActivityIndicators() }
        
        DemoService.getAll(limit: 10, delay: 0.1) { [weak self] (objects) in
            
            self?.update(objects: objects)
        }
    }
    
    override func scrollDidScroll(_ scrollView: UIScrollView) {
        
        super.scrollDidScroll(scrollView)
        
        saveContentOffset(with: scrollView.contentOffset.x)
    }
    
    // MARK: - Private methods
    
    private func saveContentOffset(with offset: CGFloat) {
        
        DemoMultiListFirstChildController.contentOffsetArray[object?.primaryKey ?? ""] = offset
    }
    
    private func loadContentOffset() {
        
        let offset = DemoMultiListFirstChildController.contentOffsetArray[object?.primaryKey ?? ""] ?? 0
        
        collectionView?.contentOffset.x = offset
    }
}

// MARK: - DemoMultiListSecondChildController

class DemoMultiListSecondChildController: DemoMultiListFirstChildController {
    
}

// MARK: - DemoMultiListThirdChildController

class DemoMultiListThirdChildController: DemoMultiListFirstChildController {
    
}
