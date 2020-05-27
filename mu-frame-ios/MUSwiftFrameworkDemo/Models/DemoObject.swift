//
//  DemoObject.swift
//  MUSwiftFramework
//
//  Created by Dmitry Smirnov on 22/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - DemoType

enum DemoType: Int, Codable {
    
    case first
    case second
    case third
}

// MARK: - DemoObject

class DemoObject: MUModel, MUCodable {
    
    override var primaryKey: String { return id ?? "" }
    
    override class var cacheControl: MUCacheControlProtocol? { return MUCacheControlManager.get(for: DemoObject.self) }
    
    // MARK: - Public properties
    
    var id: String?
    
    var color: DemoColor?
    
    var type: DemoType?
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case color
        case type
    }
    
    // MARK: - Public methods
    
    static func updateBeforeParsing( rawData: inout [String : Any]) {
        
    }
}

// MARK: - DemoColor

class DemoColor: Codable {
    
    var uiColor: UIColor {
        
        return UIColor.init(
            
            red   : CGFloat(red) / 100,
            green : CGFloat(green) / 100,
            blue  : CGFloat(blue) / 100,
            alpha : 1
        )
    }
    
    var red: Int = 0
    
    var green: Int = 0
    
    var blue: Int = 0
    
    private enum CodingKeys: String, CodingKey {
        
        case red
        case green
        case blue
    }
}
