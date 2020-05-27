//
//  UserDefaults.swift

//
//  Created by Bodygin on 05/09/2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    struct Timeout {
        
        let timestamp: Date = Date()
        
        let interval: TimeInterval
    }
    
    // MARK: - Private properties
    
    static private var timestampByKeyArray: [String: Timeout] = [:]
    
    // MARK: - Public methods
    
    class func set(_ value: Any, forKey key: String, timeout: TimeInterval) {
        
        UserDefaults.standard.set(value, forKey: key)
        
        UserDefaults.timestampByKeyArray[key] = Timeout(interval: timeout)
    }
    
    class func get(forKey key: String) -> Any? {
        
        if let timeout = UserDefaults.timestampByKeyArray[key] {
            
            let liveTimeInSeconds = Date().timeIntervalSince(timeout.timestamp)
            
            if liveTimeInSeconds >= timeout.interval {
                
                UserDefaults.timestampByKeyArray.removeValue(forKey: key)
                
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        
        return UserDefaults.standard.object(forKey: key)
    }
}
