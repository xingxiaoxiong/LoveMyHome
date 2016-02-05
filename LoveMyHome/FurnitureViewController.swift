//
//  FurnitureViewController.swift
//  LoveMyHome
//
//  Created by xingxiaoxiong on 2/5/16.
//  Copyright © 2016 BettyBearStudio. All rights reserved.
//

import UIKit
import CoreData

class FurnitureViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var furnitureList = [Furniture]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        furnitureList = fetchAllFurniture()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if furnitureList.count == 0 {
            downloadThumbnails()
        }
    }
    
    func downloadThumbnails() {
        Parse.sharedInstance().getThumbnailUrls { (parsedResult, error) -> Void in
            
            if let error = error {
                dispatch_async(dispatch_get_main_queue()) {
                    self.alertViewForError(error)
                }
            } else {
                guard let list = parsedResult as? [[String: AnyObject]] else {
                    let error = NSError(domain: "Parse API returned an error. See error code and message in \(parsedResult)", code: 0, userInfo: nil)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.alertViewForError(error)
                    }
                    return
                }
                
                if list.count > 0 {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        _ = list.map() { (dictionary: [String : AnyObject]) -> Furniture in
                            let dic: [String : AnyObject] = [
                                Furniture.Keys.Id: dictionary["objectId"]!,
                                Furniture.Keys.ModelUrl: self.forceHttps(dictionary["model_url"] as! String),
                                Furniture.Keys.ThumbnailUrl: self.forceHttps(dictionary["thumbnail_url"] as! String)
                            ]
                            
                            let furniture = Furniture(dictionary: dic, context: self.sharedContext)
                            self.furnitureList.append(furniture)
                            
                            return furniture
                        }
                        
                        self.collectionView.reloadData()
                        self.saveContext()
                    }
                }
            }
            
        }
    }
    
    func alertViewForError(error: NSError) {
        let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func forceHttps(url: String) -> String {
        if url.rangeOfString("http") != nil {
            return url.stringByReplacingOccurrencesOfString("http", withString: "https")
        } else {
            return url
        }
    }
    
    // MARK: - Core Data Convenience
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func fetchAllFurniture() -> [Furniture] {
        
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Furniture")
        
        // Execute the Fetch Request
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Furniture]
        } catch  let error as NSError {
            print("Error in fetchAllPins(): \(error)")
            return [Furniture]()
        }
    }

}


extension FurnitureViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width/3 - 5, height: collectionView.frame.size.width/3 - 2.5)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return furnitureList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let furniture = furnitureList[indexPath.row]
        var thumbnail = UIImage(named: "photoPlaceHolder")
        
        let CellIdentifier = "FurnitureCell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: indexPath) as! FurnitureCell
        cell.thumbnail.image = nil
        
//        let imageURL = NSURL(string: furniture.thumbnailUrl)
//        if let imageData = NSData(contentsOfURL: imageURL!) {
//            
//            dispatch_async(dispatch_get_main_queue(), {
//                
//                thumbnail = UIImage(data: imageData)
//                cell.thumbnail.image = thumbnail
//                furniture.thumbnail = thumbnail
//                self.saveContext()
//            })
//        }
        
        if furniture.thumbnail != nil {
            thumbnail = furniture.thumbnail
        } else {
            
            let imageURL = NSURL(string: furniture.thumbnailUrl)
            if let imageData = NSData(contentsOfURL: imageURL!) {
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    thumbnail = UIImage(data: imageData)
                    cell.thumbnail.image = thumbnail
                    furniture.thumbnail = thumbnail
                    self.saveContext()
                })
            }
            
        }
        
        cell.thumbnail.image = thumbnail
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let furniture = furnitureList[indexPath.row]
        
        guard let modelData = furniture.modelData else {
            return
        }
    }
}
