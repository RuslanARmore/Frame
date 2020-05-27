//
//  ApiCore.swift
//  MUSwiftFramework
//
//  Created by Dmitry Smirnov on 07/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import Foundation

// MARK: - ApiCore

extension ApiCore {
    
    static let production = ""
    
    static let develop = ""
}

// MARK: - ApiCore

class ApiCore: MUDataTransferManager {
    
    static let shared = ApiCore()
    
    // MARK: - Override methods
    
    override init() {
        
        super.init()
        
        networkManager?.serverUrl = MUDeployManager.isProduction ? ApiCore.production : ApiCore.develop
    }
}
