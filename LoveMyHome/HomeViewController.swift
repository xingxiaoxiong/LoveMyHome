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
    var dynamicGeometry: SCNNode = SCNNode()
    
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
        
        //debugLoadModelFromJSON()
        debugLoadModelFromDae()
        
        geometryNode.addChildNode(staticGeometry)
        geometryNode.addChildNode(dynamicGeometry)
        scene.rootNode.addChildNode(geometryNode)
        
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
        camera.position = SCNVector3Make(0, 1.6, 3)
        scene.rootNode.addChildNode(camera)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "panGesture:")
        sceneView.addGestureRecognizer(panRecognizer)
        
        sceneView.scene = scene
        //sceneView.allowsCameraControl = true
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
    
    func modelFromJson(data: NSDictionary) -> SCNNode {
        guard let positions = data["vertices"] as? [Float32] else {
            print("error casting positions")
            return SCNNode()
        }
        let positionData = NSData(bytes: positions, length: sizeof(Float32)*positions.count)
    
        guard let indices = data["faces"] as? [Int] else {
            print("error casting indices")
            return SCNNode()
        }
    
//        let faces = data["faces"] as? [AnyObject]
//        let intFaces = (faces as! [Int]).map({Int32($0)})
        let indexData = NSData(bytes: indices, length: sizeof(Int)*indices.count)
    
        let source = SCNGeometrySource(data: positionData, semantic:
                SCNGeometrySourceSemanticVertex, vectorCount: indices.count, floatComponents: true, componentsPerVector: 3, bytesPerComponent: sizeof(Float32), dataOffset: 0, dataStride: sizeof(Float32)*3)
    
        let element = SCNGeometryElement(data: indexData, primitiveType: SCNGeometryPrimitiveType.Triangles, primitiveCount: indices.count / 3, bytesPerIndex: sizeof(Int))

        let modelGeometry = SCNGeometry(sources: [source], elements: [element])
        return SCNNode(geometry: modelGeometry)
    
//        let boxGeo = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1)
//        boxGeo.firstMaterial!.diffuse.contents = UIColor.lightGrayColor()
//        return SCNNode(geometry: boxGeo)

    }
    
    func debugLoadModelFromJSON() {
        let location = NSString(string:"/Users/shapeare/Documents/misc_chair01.js").stringByExpandingTildeInPath
        let rawData = NSData(contentsOfFile: location)
        let modelData = try? NSJSONSerialization.JSONObjectWithData(rawData!, options: NSJSONReadingOptions.AllowFragments)
        
//        let dict = modelData as! NSDictionary
//        guard let vertices = dict["vertices"] as? [Float32] else {
//            print("error casting vertices")
//            return
//        }
//        guard let indices = dict["faces"] as? [Int] else {
//            print("error casting indices")
//            return
//        }
        
        let modelNode = modelFromJson(modelData as! NSDictionary)
        
        modelNode.position = SCNVector3Make(0, 0, -3)
        scene.rootNode.addChildNode(modelNode)
    }
    
    func debugLoadModelFromDae() {
        let node = SCNNode()
        let modelScene = SCNScene(named: "misc_chair01.dae")
        for child : AnyObject in modelScene!.rootNode.childNodes {
            node.addChildNode(child as! SCNNode)
        }
        node.position = SCNVector3Make(0, 0, -4)
        dynamicGeometry.addChildNode(node)
        scene.rootNode.addChildNode(node)
    }
    
}

