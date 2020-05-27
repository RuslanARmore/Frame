//
//  MUSerializationManager.swift
//
//  Created by Dmitry Smirnov on 1/02/2019.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Foundation

// MARK: - MUSerializationManager

class MUSerializationManager {
    
    // MARK: - Public methods
    
    class func encode(object: MUCodable) -> Any? {
        
        object.updateBeforeEncode()
        
        guard let dictionary = object.dictionary else {
            
            return nil
        }
        
        return dictionary
    }
    
    class func decode<Object: MUCodable>(item: [String: Any], to objectType: Object.Type) -> Object? {
        
        var item = item
        
        Object.updateBeforeParsing(rawData: &item)
        
        guard let objectData = getData(from: item) else {
            
            return nil
        }
        
        do {
            
            let decoder = JSONDecoder()
            
            decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
                
                let container  = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                let date = Formatter.iso8601.date(from: dateString)
                
                return date ?? Formatter.zeroDate
            })
            
            let object = try decoder.decode(objectType, from: objectData)
            
            object.updateAfterDecode()
            
            return object
            
        } catch let error {
            
            Log.error("error: \(error) \n \(item)")
        }
        
        return nil
    }
    
    class func copy<Object: MUCodable>(object: MUCodable, to objectType: Object.Type) -> Object? {
        
        guard let copy = encode(object: object) as? [String : Any] else {
            
            return nil
        }
        
        return decode(item: copy, to: Object.self)
    }
    
    // MARK: - Private methods
    
    private class func getData(from dictionary: [String: Any]) -> Data? {
        
        do {
            
            return try JSONSerialization.data(withJSONObject: dictionary)
            
        } catch let error {
            
            Log.error("error: \(error)")
        }
        
        return nil
    }
}
