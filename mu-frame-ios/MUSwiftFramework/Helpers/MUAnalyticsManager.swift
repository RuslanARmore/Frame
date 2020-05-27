//
//  MUAnalyticsManager.swift
//
//  Created by Dmitry Smirnov on 1/02/2019.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Fabric
import Crashlytics

class MUAnalyticsManager {
    
    static let shared = MUAnalyticsManager()
    
    // Public methods

    func setup() {
        
        Fabric.with([Crashlytics.self])
    }
}
