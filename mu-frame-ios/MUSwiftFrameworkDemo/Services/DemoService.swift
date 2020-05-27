//
//  DemoService.swift
//  MUSwiftFramework
//
//  Created by Dmitry Smirnov on 22/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - DemoService

class DemoService: NSObject {
    
    // MARK: - Public properties
    
    static var limit = 20
    
    // MARK: - Public methods

    static func getAll(limit: Int = DemoService.limit, delay: TimeInterval = 0.3, success: @escaping ([DemoObject]) -> Void) {
        
        var response: [[String: Any]] = []
        
        for _ in 1...limit {
            
            response.append([
                
                "id"    : UUID().uuidString,
                "type"  : Int.rand(min: 0, max: 2),
                "color" : [
                    
                    "red"   : Int.rand(min: 0, max: 100),
                    "green" : Int.rand(min: 0, max: 100),
                    "blue"  : Int.rand(min: 0, max: 100)
                ]
            ])
        }
        
        if Int.rand(min: 0, max: 36) == 0 {
            
            ApiCore.addResponse(withError: MUNetworkError.connectionError, delay: 0.5)
        } else {
            ApiCore.addResponse(with: response, delay: delay)
        }
        
        ApiCore.shared.getObjects(
            
            from    : "demo/getObjects",
            to      : DemoObject.self,
            success : { objects in success(objects) }
        )
    }
}
