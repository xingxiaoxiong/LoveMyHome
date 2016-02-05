//
//  Furniture.swift
//  LoveMyHome
//
//  Created by xingxiaoxiong on 2/5/16.
//  Copyright © 2016 BettyBearStudio. All rights reserved.
//

import UIKit
import CoreData

class Furniture: NSManagedObject {
    
    struct Keys {
        static let Id = "id"
        static let ThumbnailUrl = "thumbnailUrl"
        static let ModelUrl = "modelUrl"
    }
    
    @NSManaged var id: String
    @NSManaged var modelUrl: String
    @NSManaged var thumbnailUrl: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Furniture", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        id = dictionary[Keys.Id] as! String
        modelUrl = dictionary[Keys.ModelUrl] as! String
        thumbnailUrl = dictionary[Keys.ThumbnailUrl] as! String
    }
    
    var modelData: NSData? {
        
        get {
            return Parse.Caches.modelCache.dataWithIdentifier(id + "model")
        }
        
        set {
            Parse.Caches.modelCache.storeData(newValue, withIdentifier: id + "model")
        }
    }
    
    var thumbnail: UIImage? {
        
        get {
            return Parse.Caches.imageCache.imageWithIdentifier(id)
        }
        
        set {
            Parse.Caches.imageCache.storeImage(newValue, withIdentifier: id)
        }
    }
    
}