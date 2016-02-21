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
    }
    
    var node: SCNNode
    
    init(_node: SCNNode) {
        node = _node
    }
    
    func encodeWithCoder(archiver: NSCoder) {
        archiver.encodeObject(node, forKey: Keys.Node)
    }
    
    required init(coder unarchiver: NSCoder) {
        node = unarchiver.decodeObjectForKey(Keys.Node) as! SCNNode
        super.init()
    }
}
