//
//  DemoSectionsController.swift
//  MUSwiftFramework
//
//  Created by Dmitry Smirnov on 01/03/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - DemoSectionsController

class DemoSectionsController: ListController {
    
    class override var storyboardName: String { return "DemoList" }
    
    // MARK: - Override properties
    
    override var hasRefresh: Bool { return true }
    
    override var hasPagination: Bool { return true }
    
    override var hasEmptyState: Bool { return true }
    
    override var hasCache: Bool { return true }
    
    override var cacheControl : MUCacheControlProtocol? { return DemoObject.cacheControl }
    
    override var behaviors: BehaviorOptions { return BehaviorPreset.defaultTab }
    
    // MARK: - Private properties
    
    @IBOutlet private weak var tableProvider: UITableView! { didSet { tableView = tableProvider } }
    
    @IBOutlet private weak var emptyViewProvider: UIView! { didSet { emptyView = emptyViewProvider } }
    
    // MARK: - Override methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableControl.reservePosition(at: 0, forCell: "CellForFirstSection")
        
        tableControl.reservePosition(at: 3, forCell: "CellForSecondSection")
        
        tableControl.reservePosition(at: 5, forCell: "CellForFirstSection")
        
        tableControl.reservePosition(at: 8, forCell: "CellForSecondSection")
        
        tableControl.reservePosition(at: 15, forCell: "CellForFirstSection")
        
        tableControl.reservePosition(at: 20, forCell: "CellForSecondSection")
        
        tableControl.reservePosition(at: 35, forCell: "CellForFirstSection")
        
        tableControl.reservePosition(at: 40, forCell: "CellForSecondSection")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            
            self?.tableControl.removeReserve(at: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            
            self?.tableControl.reservePosition(at: 1, forCell: "CellForFirstSection")
            
            self?.tableControl.removeReserve(at: 3)
        }
    }
    
    override func beginRequest() {
        
        DemoService.getAll() { [weak self] (objects) in
            
            self?.update(objects: objects)
        }
    }
    
    override func cellDidSelected(for object: MUModel) {
        
        DemoListItemController.push(to: self)
    }
}
