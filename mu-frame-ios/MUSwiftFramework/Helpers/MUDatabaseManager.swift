//
//  MUDatabaseManager.swift
//  MUSwiftFramework
//
//  Created by Maxim Aliev on 25/03/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import RealmSwift

// MARK: - MUDatabaseManager

final class MUDatabaseManager {
    
    // MARK: - Private properties
    
    private let realm = try! Realm()
    
    // MARK: - Public methods
    
    func fetch<Model, T>(with predicate: NSPredicate?, sortDescriptiors: [SortDescriptor], transformer: (Results<T>) -> Model) -> Model where T: Object {
        
        var results = realm.objects(T.self)
        
        if let predicate = predicate {
            
            results = results.filter(predicate)
        }
        
        if !sortDescriptiors.isEmpty {
            
            results = results.sorted(by: sortDescriptiors)
        }
        
        return transformer(results)
    }
    
    func createOrUpdate<Model, T>(model: Model, transformer: (Model) -> T) where T: Object {
        
        let object = transformer(model)
        
        try! realm.write {
            
            realm.add(object, update: .all)
        }
    }
    
    func delete<T>(type: T.Type, with primaryKey: String) where T: Object {
        
        let object = realm.object(ofType: type, forPrimaryKey: primaryKey)
        
        if let object = object {
            
            try! realm.write {
                
                realm.delete(object)
            }
        }
    }
}

