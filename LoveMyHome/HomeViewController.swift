//
//  ViewController.swift
//  LoveMyHome
//
//  Created by xingxiaoxiong on 2/4/16.
//  Copyright © 2016 BettyBearStudio. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var sceneView: SCNView!
    
    var scene: SCNScene = SCNScene()
    var camera: SCNNode = SCNNode()
    var geometryNode: SCNNode = SCNNode()
    var staticGeometry: SCNNode = SCNNode()
    
    var currentAngle: Float = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func sceneSetup () {
        scene = SCNScene()
        
        // Constructing basic structure
        let leftWallGeometry = SCNBox(width: Constants.WallThickness, height: Constants.RoomYLength, length: Constants.RoomZLength, chamferRadius: 0.0)
        leftWallGeometry.firstMaterial!.diffuse.contents = UIColor.lightGrayColor()
        let leftWallNode = SCNNode(geometry: leftWallGeometry)
        leftWallNode.position = SCNVector3Make(-Float(Constants.RoomXLength) / 2.0, Float(Constants.RoomYLength) / 2.0, 0)
        staticGeometry.addChildNode(leftWallNode)
        
        let rightWallGeometry = SCNBox(width: Constants.WallThickness, height: Constants.RoomYLength, length: Constants.RoomZLength, chamferRadius: 0.0)
        rightWallGeometry.firstMaterial!.diffuse.contents = UIColor.lightGrayColor()
        let rightWallNode = SCNNode(geometry: rightWallGeometry)
        rightWallNode.position = SCNVector3Make(Float(Constants.RoomXLength) / 2.0, Float(Constants.RoomYLength) / 2.0, 0)
        staticGeometry.addChildNode(rightWallNode)

        let floorGeometry = SCNBox(width: Constants.RoomXLength, height: Constants.WallThickness, length: Constants.RoomZLength, chamferRadius: 0.0)
        floorGeometry.firstMaterial!.diffuse.contents = UIColor.lightGrayColor()
        let floorNode = SCNNode(geometry: floorGeometry)
        floorNode.position = SCNVector3Make(0, -Float(Constants.WallThickness) / 2.0, 0)
        staticGeometry.addChildNode(floorNode)

        let ceilingGeometry = SCNBox(width: Constants.RoomXLength, height: Constants.WallThickness, length: Constants.RoomZLength, chamferRadius: 0.0)
        ceilingGeometry.firstMaterial!.diffuse.contents = UIColor.lightGrayColor()
        let ceilingNode = SCNNode(geometry: ceilingGeometry)
        ceilingNode.position = SCNVector3Make(0, Float(Constants.RoomYLength), 0)
        staticGeometry.addChildNode(ceilingNode)
        
        let frontGeometry = SCNBox(width: Constants.RoomXLength, height: Constants.RoomYLength, length: Constants.WallThickness, chamferRadius: 0.0)
        frontGeometry.firstMaterial!.diffuse.contents = UIColor.lightGrayColor()
        let frontNode = SCNNode(geometry: frontGeometry)
        frontNode.position = SCNVector3Make(0, Float(Constants.RoomYLength) / 2.0, -Float(Constants.RoomZLength) / 2.0)
        staticGeometry.addChildNode(frontNode)
        
        let backGeometry = SCNBox(width: Constants.RoomXLength, height: Constants.RoomYLength, length: Constants.WallThickness, chamferRadius: 0.0)
        backGeometry.firstMaterial!.diffuse.contents = UIColor.lightGrayColor()
        let backNode = SCNNode(geometry: backGeometry)
        backNode.position = SCNVector3Make(0, Float(Constants.RoomYLength) / 2.0, Float(Constants.RoomZLength) / 2.0)
        staticGeometry.addChildNode(backNode)
        
        geometryNode.addChildNode(staticGeometry)
        scene.rootNode.addChildNode(geometryNode)
        
        debugLoadModel()
        
        let pointLightNode = SCNNode()
        pointLightNode.light = SCNLight()
        pointLightNode.light!.type = SCNLightTypeOmni
        pointLightNode.light!.color = UIColor(red: 1.0, green: 0.839, blue: 0.667, alpha: 1.0)
        pointLightNode.position = SCNVector3Make(0, Float(Constants.RoomYLength) / 2.0, -Float(Constants.RoomZLength) / 2.0 + 2.0 * Float(Constants.WallThickness))
        scene.rootNode.addChildNode(pointLightNode)
        
        let pointLightNode2 = SCNNode()
        pointLightNode2.light = SCNLight()
        pointLightNode2.light!.type = SCNLightTypeOmni
        pointLightNode2.light!.color = UIColor(red: 1.0, green: 0.945, blue: 0.878, alpha: 1.0)
        pointLightNode2.position = SCNVector3Make(Float(Constants.RoomXLength) / 2.0 - 2.0 * Float(Constants.WallThickness), Float(Constants.RoomYLength) / 2.0, Float(Constants.RoomZLength) / 2.0 - 2.0 * Float(Constants.WallThickness))
        scene.rootNode.addChildNode(pointLightNode2)
        
        camera.camera = SCNCamera()
        camera.position = SCNVector3Make(0, 1.6, 0)
        scene.rootNode.addChildNode(camera)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "panGesture:")
        sceneView.addGestureRecognizer(panRecognizer)
        
        sceneView.scene = scene
    }
    
    func panGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(sender.view!)
        var newAngle = (Float)(translation.x)*(Float)(M_PI)/180.0
        newAngle += currentAngle

        camera.eulerAngles.y = newAngle
            
        if(sender.state == UIGestureRecognizerState.Ended) {
            currentAngle = newAngle
        }
    }
    
    func debugLoadModel() {
        let location = NSString(string:"/Users/shapeare/Documents/misc_chair01.js").stringByExpandingTildeInPath
        print(location)
        let fileContent = try? NSString(contentsOfFile: location, encoding: NSUTF8StringEncoding)
        print(fileContent)
    }
    
}

