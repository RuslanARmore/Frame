//
//  MUEmptyStateControl.swift
//
//  Created by Dmitry Smirnov on 01/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MUEmptyStateControl

class MUEmptyStateControl: NSObject {
    
    // MARK: - Public properties
    
    weak var emptyView: UIView?
    
    var isHidden: Bool = true { didSet { updateVisibility() } }
    
    // MARK: - Private properties
    
    private weak var contentView: UIView?
    
    private weak var emptyTableView: UITableView?
    
    private let refreshControl = MURefreshControl()
    
    // MARK: - Public methods
    
    func setup(with controller: MUListController) {
        
        guard controller.hasEmptyState, emptyView != nil else { return }
        
        self.contentView = controller.tableView ?? controller.collectionView
        
        configureEmptyState(with: controller.hasRefresh ? controller.refreshControl : nil)
    }
    
    func stopAnimation() {
        
        refreshControl.stopAnimation()
    }
    
    func updateLayout() {
        
        emptyTableView?.viewForFooter(with: emptyView)
    }
    
    // MARK: - Private methods

    private func configureEmptyState(with refreshControl: MURefreshControl?) {
        
        guard self.emptyTableView == nil, let contentView = contentView else { return }
        
        let emptyTableView = UITableView(frame: contentView.frame)
        
        emptyTableView.backgroundColor = .clear
        
        emptyTableView.viewForFooter(with: emptyView)
        
        contentView.superview?.addSubview(emptyTableView)
        
        emptyTableView.appendConstraints(to: contentView)
        
        self.emptyTableView = emptyTableView
        
        updateVisibility()
        
        guard let refreshControl = refreshControl else { return }
        
        self.refreshControl.setup(with: self.emptyTableView, delegate: refreshControl.delegate, tintColor: refreshControl.tintColor)
    }
    
    private func updateVisibility() {
        
        emptyTableView?.isHidden = isHidden
        
        emptyTableView?.setFooterVisibility(asHidden: isHidden)
    }
}
