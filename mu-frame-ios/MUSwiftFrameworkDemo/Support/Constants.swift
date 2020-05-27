//
//  Constants.swift

//
//  Created by Dmitry Smirnov on 22.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

class Constants: NSObject {
    
    static let bundle = Bundle(for: Constants.self)
    
    static var shouldLogConstraintsWarnings = true { didSet { updateLogConstraintsWarnings() } }
    
    // MARK: - Public methods
    
    static func configure() {
        
        shouldLogConstraintsWarnings = false
    }
    
    // MARK: - Private methods
    
    private static func updateLogConstraintsWarnings() {
        
        UserDefaults.standard.setValue(shouldLogConstraintsWarnings, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
    }
}
