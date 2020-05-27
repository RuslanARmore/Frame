//
//  DemoCollectionController.swift
//  MUSwiftFramework
//
//  Created by Dmitry Smirnov on 04/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - DemoCollectionController

class DemoCollectionController: ListController {
    
    // MARK: - Override properties
    
    override var hasRefresh: Bool { return true }
    
    override var hasPagination: Bool { return true }
    
    override var hasEmptyState: Bool { return true }
    
    override var hasCache: Bool { return true }
    
    override var cacheControl: MUCacheControlProtocol? { return DemoObject.cacheControl }
    
    override var behaviors: BehaviorOptions { return BehaviorPreset.defaultTab }
    
    // MARK: - Private properties

    @IBOutlet private weak var collectionProvider: UICollectionView! { didSet { collectionView = collectionProvider } }
    
    @IBOutlet private weak var emptyViewProvider: UIView! { didSet { emptyView = emptyViewProvider } }
    
    // MARK: - Override methods
    
    override func beginRequest() {
        
        DemoService.getAll() { [weak self] (objects) in
            
            self?.update(objects: objects)
        }
    }
    
    override func cellDidSelected(for object: MUModel) {
        
        DemoListItemController.push(to: self)
    }
    
    override func cellIdentifier(for object: MUModel, at indexPath: IndexPath) -> String? {
        
        guard let object = object as? DemoObject else { return nil }
        
        switch object.type ?? .first {
            
        case .first  : return "Cell"
        case .second : return "SecondCell"
        case .third  : return "SecondCell"
        }
    }
}

// MARK: - DemoCollectionCell

class DemoCollectionCell: MUCollectionCell {
    
    // MARK: - Public properties
    
    @IBOutlet private weak var containerView: View!
    
    // MARK: - Override methods
    
    override func setup(with object: MUModel, sender: Any?) {
        
        super.setup(with: object)
        
        guard let color = (object as? DemoObject)?.color?.uiColor else { return }
        
        containerView.backgroundColor = color
    }
}
