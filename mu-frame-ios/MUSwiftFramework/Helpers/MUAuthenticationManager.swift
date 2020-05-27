//
//  MUAuthenticationManager.swift
//
//  Created by Dmitry Smirnov on 1/02/2019.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit
import LocalAuthentication

// MARK: - BiometricType

enum BiometricType {
    
    case faceId, touchId, none
}

// MARK: - MUAuthenticationManager

class MUAuthenticationManager {
    
    static var biometricType: BiometricType { return getBiometricType() }
    
    // MARK: - Private properties

    private static let context = LAContext()
    
    // MARK: - Public methods
    
    class func authWithBiometrics(message: String, completion: ((Bool) -> Void)? = nil) {
        
        guard #available(iOS 8.0, macOS 10.12.1, *) else {
            
            Log.show("error: touchId unavailable")
            
            completion?(false)
            return
        }
        
        guard canAuthenticationWithBiometrics() else {
            
            completion?(false)
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: message) { success, evaluateError in
            
            DispatchQueue.main.async {
                
                if success {
                    
                    completion?(true)
                    
                } else {
                    
                    Log.error("error: failure \(String(describing: evaluateError))")
                    
                    completion?(false)
                }
            }
        }
    }
    
    class func canAuthenticationWithBiometrics() -> Bool {
        
        var error: NSError?
        
        let result = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if let error = error {
            
            Log.error("error: \(String(describing: error))")
        }
        
        return result
    }
    
    class func getBiometricType() -> BiometricType {
        
        guard canAuthenticationWithBiometrics() else {
            
            return .none
        }
        
        if #available(iOS 11.0, *) {
            
            switch context.biometryType {
            case .touchID : return .touchId
            case .faceID  : return .faceId
            default       : return .none
            }
            
        }
        
        return .touchId
    }

}
