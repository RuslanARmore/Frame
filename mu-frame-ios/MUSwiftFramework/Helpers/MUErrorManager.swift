//
//  MUErrorManager.swift
//  MUSwiftFramework
//
//  Created by Dmitry Smirnov on 22/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MUErrorNotification

struct MUErrorNotification {
    
    let error: Error
    
    let recipient: NSObject?
}

// MARK: - MUErrorManager

class MUErrorManager: Error {
    
    // MARK: - Public properties
    
    static weak var recipient: NSObject?
    
    // MARK: - Public methods
    
    static func post(with error: Error, for recipient: NSObject? = nil) {
        
        let notification = MUErrorNotification(
            
            error     : error,
            recipient : recipient ?? MUErrorManager.recipient
        )
        
        NotificationCenter.default.post(name: .appErrorDidCome, object: nil, userInfo: [
            
            "error"        : error,
            "notification" : notification
        ])
    }
}

// MARK: - Notification

extension Notification.Name {
    
    static let appErrorDidCome = Notification.Name("appErrorDidCome")
}
