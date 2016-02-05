//
//  DataCache.swift
//  LoveMyHome
//
//  Created by xingxiaoxiong on 2/5/16.
//  Copyright © 2016 BettyBearStudio. All rights reserved.
//

import UIKit

class DataCache {
    
    private var inMemoryCache = NSCache()
    
    // MARK: - Retreiving data
    
    func dataWithIdentifier(identifier: String?) -> NSData? {
        
        // If the identifier is nil, or empty, return nil
        if identifier == nil || identifier! == "" {
            return nil
        }
        
        let path = pathForIdentifier(identifier!)
        
        // First try the memory cache
        if let data = inMemoryCache.objectForKey(path) {
            return data as? NSData
        }
        
        // Next Try the hard drive
        if let data = NSData(contentsOfFile: path) {
            return data
        }
        
        return nil
    }
    
    // MARK: - Saving data
    
    func storeData(data: NSData?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)
        
        // If the image is nil, remove images from the cache
        if data == nil {
            inMemoryCache.removeObjectForKey(path)
            
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            } catch _ {}
            
            return
        }
        
        // Otherwise, keep the data in memory
        inMemoryCache.setObject(data!, forKey: path)
        
        // And in documents directory
        data!.writeToFile(path, atomically: true)
    }
    
    // MARK: - Helper
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }
}
