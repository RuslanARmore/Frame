//
//  MUModel.swift
//
//  Created by Dmitry Smirnov on 03/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import RealmSwift

// MARK: - MUModel

class MUModel: Object {
    
    // MARK: - Public properties
    
    var primaryKey: String { return defaultKey ?? "" }
    
    class var cacheControl: MUCacheControlProtocol? { return nil }
    
    var defaultKey: String?
    
    // MARK: - Public methods
    
    func updateBeforeEncode() { }
    
    func updateAfterDecode() { }
}

// MARK: - MUCodable

protocol MUCodable: Codable {
    
    func updateBeforeEncode()
    
    func updateAfterDecode()
    
    static func updateBeforeParsing( rawData: inout [String : Any])
}
