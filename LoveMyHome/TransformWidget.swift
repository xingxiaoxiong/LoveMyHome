//
//  TransformWidget.swift
//  LoveMyHome
//
//  Created by xingxiaoxiong on 2/4/16.
//  Copyright © 2016 BettyBearStudio. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class TransformWidget {
    
    var widgetNode: SCNNode = SCNNode()
    
    var xAxis: SCNNode
    var yAxis: SCNNode
    var zAxis: SCNNode
    
    init(node: SCNNode) {
        let parent = node.parentNode
        node.removeFromParentNode()
        
        widgetNode.addChildNode(node)
        widgetNode.name = "transform"
        parent?.addChildNode(widgetNode)
        
        let yGeometry = SCNCylinder(radius: 0.03, height: 3.0)
        yGeometry.firstMaterial?.diffuse.contents = UIColor.blueColor()
        yAxis = SCNNode(geometry: yGeometry)
        yAxis.position = node.position
        
        xAxis = SCNNode()
        zAxis = SCNNode()
        
        widgetNode.addChildNode(xAxis)
        widgetNode.addChildNode(yAxis)
        widgetNode.addChildNode(zAxis)
    }
    
}