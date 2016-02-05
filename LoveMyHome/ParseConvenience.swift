//
//  ParseConvenience.swift
//  LoveMyHome
//
//  Created by xingxiaoxiong on 2/5/16.
//  Copyright © 2016 BettyBearStudio. All rights reserved.
//

import Foundation

extension Parse {
    
    func getThumbnailUrls(completionHandler: CompletionHandler) {
        
        let parameters:[String : AnyObject] = ["": ""]
        
        Parse.sharedInstance().taskForResource(parameters, completionHandler: { (result, error) -> Void in
            
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                
                guard let parsedResult = result as? NSDictionary else {
                    let error = NSError(domain: "Parse API returned an error. See error code and message in \(result)", code: 0, userInfo: nil)
                    completionHandler(result: nil, error: error)
                    return
                }
                
                guard let furnitureList = parsedResult["results"] else {
                    let error = NSError(domain: "Cannot find keys 'results' in \(parsedResult)", code: 0, userInfo: nil)
                    completionHandler(result: nil, error: error)
                    return
                }
                
                completionHandler(result: furnitureList, error: nil)
            }
        })

    }
    
}