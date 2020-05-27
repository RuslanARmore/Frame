//
//  MUBehaviorController.swift
//
//  Created by Dmitry Smirnov on 04/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MUBehaviorController

class MUBehaviorController: NSObject {
    
    // MARK: - Public properties
    
    var behaviorManager = MUBehaviorManager()
    
    // MARK: - Public methods
    
    func check(behavior: String, processed: Bool = true) -> Bool {
        
        return behaviorManager.checkIsExist(with: behavior, asProcessed: processed)
    }
    
    func checkIsNotRun(behavior: String) -> Bool {
        
        return behaviorManager.checkIsNotRun(with: [behavior])
    }
    
    func checkIsNotRun(behaviors: [String]) -> Bool {
        
        return behaviorManager.checkIsNotRun(with: behaviors)
    }
    
    func getNumberOfRuns(behavior: String) -> Int {
        
        return behaviorManager.getNumberOfRuns(withBehaviour: behavior)
    }
    
    func waitFor(behavior: String, completion: @escaping () -> Void) {
        
        return behaviorManager.wait(for: behavior, completion: completion)
    }
    
    func waitFor(behaviors: String, completion: @escaping () -> Void) {
        
        return behaviorManager.wait(for: behaviors, completion: completion)
    }
}
