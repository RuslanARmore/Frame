//
//  MUCacheControl.swift
//  MUSwiftFramework
//
//  Created by Dmitry Smirnov on 03/03/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MUCacheControlProtocol

protocol MUCacheControlProtocol {
    
    func setup(with controller: MUListController)
    
    func save()
    
    func load()
    
    func setCacheKey(with key: String?)
}

// MARK: - MUCacheControlManager

class MUCacheControlManager {
    
    // MARK: - Public properties
    
    static var instanceArray: [String: MUCacheControlProtocol] = [:]
    
    // MARK: - Public methods
    
    static func get<T: MUCodable>(for model: T.Type) -> MUCacheControlProtocol {
        
        let key = "\(T.self)"
        
        if instanceArray[key] == nil  {
            
            instanceArray[key] = MUCacheControl<T>()
        }
        
        return instanceArray[key]!
    }
}

// MARK: - MUCacheControl

class MUCacheControl<Model: MUCodable>: MUCacheControlProtocol {
    
    // MARK: - Public methods
    
    weak var controller: MUListController?
    
    var cacheKey: String?
    
    var defaultKey: String { return controller?.className ?? "" }
    
    // MARK: - Public methods
    
    func setup(with controller: MUListController) {
        
        guard controller.hasCache else { return }
        
        self.controller = controller
    }
    
    func save() {
        
        guard let objects = controller?.objects as? [MUCodable] else { return }
        
        guard controller?.paginationControl.page == 1 else { return }
        
        MUCacheManager.cache(objects: objects, forKey: cacheKey ?? defaultKey)
    }
    
    func load() {
        
        guard controller?.hasCache ?? false else { return }
        
        guard let objects = MUCacheManager.read(forKey: cacheKey ?? defaultKey, to: Model.self) as? [MUModel] else {
            
            return            
        }
        
        controller?.objects = objects
    }
    
    func setCacheKey(with key: String?) {
        
        cacheKey = key
    }
}
