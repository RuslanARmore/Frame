//
//  MUDeployManager.swift
//
//  Created by Dmitry Smirnov on 1/02/2019.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MUDeployManager

class MUDeployManager: NSObject {
    
    // MARK: - Public properties
    
    static var device: UIUserInterfaceIdiom { return UIDevice.current.userInterfaceIdiom }
    
    static var isPhone: Bool { return device == .phone }
    
    static var isPad: Bool { return device == .pad }
    
    // MARK: - Delploy properties
    
    static var isIBTarget: Bool {
        #if TARGET_INTERFACE_BUILDER
            return true
        #else
            return false
        #endif
    }
    
    static var isAppstore: Bool {
        #if APPSTORE
            return true
        #else
            return false
        #endif
    }
    
    static var isRelease: Bool {
        #if RELEASE
            return true
        #else
            return false
        #endif
    }
    
    static var isDebug: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
    
    static let isProduction: Bool = MUDeployManager.isAppstore
}
