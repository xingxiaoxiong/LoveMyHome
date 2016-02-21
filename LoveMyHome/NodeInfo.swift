//
//  NodeInfo.swift
//  LoveMyHome
//
//  Created by xingxiaoxiong on 2/21/16.
//  Copyright © 2016 BettyBearStudio. All rights reserved.
//

import Foundation
import SceneKit

class NodeInfo : NSObject, NSCoding {
    
    struct Keys {
        static let Node = "Node"
        static let PositionX = "PositionX"
        static let PositionY = "PositionY"
        static let PositionZ = "PositionZ"
        static let RotationX = "RotationX"
        static let RotationY = "RotationY"
        static let RotationZ = "RotationZ"
    }
    
    var node: SCNNode
//    var position: SCNVector3
//    var rotation: SCNVector3
    
    init(_node: SCNNode) {
        node = _node
    }
    
    func encodeWithCoder(archiver: NSCoder) {
        
        archiver.encodeObject(node, forKey: Keys.Node)
        
//        archiver.encodeFloat(position.x, forKey: Keys.PositionX)
//        archiver.encodeFloat(position.y, forKey: Keys.PositionY)
//        archiver.encodeFloat(position.z, forKey: Keys.PositionZ)
//        
//        archiver.encodeFloat(rotation.x, forKey: Keys.RotationX)
//        archiver.encodeFloat(rotation.y, forKey: Keys.RotationY)
//        archiver.encodeFloat(rotation.z, forKey: Keys.RotationZ)
    }
    
    required init(coder unarchiver: NSCoder) {
        
        node = unarchiver.decodeObjectForKey(Keys.Node) as! SCNNode
        
//        position = SCNVector3Make(unarchiver.decodeFloatForKey(Keys.PositionX), unarchiver.decodeFloatForKey(Keys.PositionY), unarchiver.decodeFloatForKey(Keys.PositionZ))
//        
//        rotation = SCNVector3Make(unarchiver.decodeFloatForKey(Keys.RotationX), unarchiver.decodeFloatForKey(Keys.RotationY), unarchiver.decodeFloatForKey(Keys.RotationZ))
        
        super.init()
    }
}
