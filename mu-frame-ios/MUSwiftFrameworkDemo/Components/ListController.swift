//
//  ListController.swift

//
//  Created by Dmitry Smirnov on 04/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - ListController

class ListController: MUListController {
    
    // MARK: - Public properties
    
    var behaviorController: BehaviorController!
    
    var behaviors: BehaviorOptions { return [] }
    
    // MARK: - Override methods
    
    override func viewDidLoad() {
        
        behaviorController = BehaviorController(with: self, options: behaviors)
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        behaviorController.isPresented = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        behaviorController.isPresented = false
    }
    
    override func appErrorDidBecome(error: Error) {
        
        super.appErrorDidBecome(error: error)
        
        behaviorController.lastError = error
    }
    
    override func update(objects newObjects: [MUModel]) {
        
        super.update(objects: newObjects)
        
        behaviorController.isNoData = objects.count == 0
        
        behaviorController.isDataUpdated = true
    }
}
