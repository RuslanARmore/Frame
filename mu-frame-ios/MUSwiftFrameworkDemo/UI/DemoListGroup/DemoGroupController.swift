//
//  DemoGroupController.swift
//  MUSwiftFramework
//
//  Created by Dmitry Smirnov on 01/03/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - DemoGroupController

class DemoGroupController: ListController {
    
    class override var storyboardName: String { return "DemoListGroup" }
    
    // MARK: - Override properties
    
    override var hasRefresh: Bool { return true }
    
    override var hasPagination: Bool { return false }
    
    override var hasEmptyState: Bool { return true }
    
    override var hasCache: Bool { return true }
    
    override var cacheControl: MUCacheControlProtocol? { return DemoObject.cacheControl }
    
    override var behaviors: BehaviorOptions { return BehaviorPreset.defaultTab }
    
    // MARK: - Private properties
    
    @IBOutlet private weak var tableProvider: UITableView! { didSet { tableView = tableProvider } }
    
    @IBOutlet private weak var emptyViewProvider: UIView! { didSet { emptyView = emptyViewProvider } }
    
    // MARK: - Override methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableControl.hasSections = true
    }
    
    override func beginRequest() {
        
        DemoService.getAll(limit: 50) { [weak self] (objects) in
            
            self?.update(objects: objects)
        }
    }
    
    override func cellDidSelected(for object: MUModel) {
        
        DemoListItemController.push(to: self)
    }
    
    override func getSection(for object: MUModel) -> String? {
        
        guard let object = object as? DemoObject else { return nil }
        
        let red = object.color?.red ?? 0
        
        let green = object.color?.green ?? 0
        
        let blue = object.color?.blue ?? 0
        
        if red > green && red > blue {
            
            return "Red"
            
        } else if green > red && green > blue {
            
            return "Green"
            
        } else {
            
            return "Blue"            
        }
    }
}

// MARK: - DemoColorSection

class DemoColorSection: MUTableSection {
    
    // MARK: - Private properties
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK: - Override methods
    
    override func setup(with section: String) {
        
        titleLabel.aText = section
    }
}
