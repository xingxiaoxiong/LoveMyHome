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
    
    enum State {
        case Normal, Translate, Rotate
    }
    
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var translateButton: UIButton!
    @IBOutlet weak var rotateButton: UIButton!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    @IBOutlet weak var roomWidthTextField: UITextField!
    @IBOutlet weak var roomLengthTextField: UITextField!
    
    let RoomWidthKey = "Room Width Key"
    let RoomLengthKey = "Room Length Key"
    
    var roomWidth: Float = 0.0
    var roomLength: Float = 0.0
    
    var scene: SCNScene = SCNScene()
    var camera: SCNNode = SCNNode()
    var cameraOrbit: SCNNode = SCNNode()
    var geometryNode: SCNNode = SCNNode()
    var staticGeometry: SCNNode = SCNNode()
    var dynamicGeometry: SCNNode = SCNNode()
    
    // Room structure
    var leftWallNode: SCNNode = SCNNode()
    var rightWallNode: SCNNode = SCNNode()
    var frontNode: SCNNode = SCNNode()
    var backNode: SCNNode = SCNNode()
    var floorNode: SCNNode = SCNNode()
    
    var state: State = .Normal
    var selectedNode: SCNNode = SCNNode()
    
    // view
    var cameraXRot: Float = 0.0
    var geoZRot: Float = 0.0
    
    var myDesign = [NodeInfo]()
    
    var designFilePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        return url.URLByAppendingPathComponent("myDesign").path!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myDesign = NSKeyedUnarchiver.unarchiveObjectWithFile(designFilePath) as? [NodeInfo] ?? [NodeInfo]()
        
        roomWidth = NSUserDefaults.standardUserDefaults().floatForKey(RoomWidthKey)
        if roomWidth <= 0.01 {
            roomWidth = 5.0
            NSUserDefaults.standardUserDefaults().setFloat(roomWidth, forKey: RoomWidthKey)
        }
        roomLength = NSUserDefaults.standardUserDefaults().floatForKey(RoomLengthKey)
        if roomLength <= 0.01 {
            roomLength = 10.0
            NSUserDefaults.standardUserDefaults().setFloat(roomLength, forKey: RoomLengthKey)
        }
        
        roomWidthTextField.text = NSString(format: "%.2f", roomWidth)
         as String
        roomLengthTextField.text = NSString(format: "%.2f", roomLength)
            as String
        
        sceneSetup()
        
        disableAllButtons()
    }
    
    @IBAction func translateButtonTapped(sender: UIButton) {
        state = .Translate
        rotateButton.enabled = true
        translateButton.enabled = false
    }
    
    @IBAction func rotateButtonTapped(sender: UIButton) {
        state = .Rotate
        translateButton.enabled = true
        rotateButton.enabled = false
    }
    
    @IBAction func completeButtonTapped(sender: UIButton) {
        state = .Normal
        disableAllButtons()
    }

    @IBAction func deleteButtonTapped(sender: UIButton) {
        selectedNode.removeFromParentNode()
        disableAllButtons()
    }
    
    @IBAction func findFurnitureTapped(sender: UIBarButtonItem) {
        
        let controller =
        storyboard!.instantiateViewControllerWithIdentifier("FurnitureViewController")
            as! FurnitureViewController
        
        controller.delegate = self
        
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    @IBAction func clearSceneButtonTapped(sender: UIButton) {
        for node in dynamicGeometry.childNodes {
            node.removeFromParentNode()
        }
        disableAllButtons()
    }
    
    @IBAction func SaveButtonTapped(sender: UIButton) {
        saveDesign()
    }
    
    @IBAction func zoomInButtonTapped(sender: UIButton) {
        camera.camera?.orthographicScale--
        if camera.camera?.orthographicScale < 3 {
            camera.camera?.orthographicScale = 3
            zoomInButton.enabled = false
        }
        zoomOutButton.enabled = true
    }
    
    @IBAction func zoomOutButtonTapped(sender: UIButton) {
        camera.camera?.orthographicScale++
        if camera.camera?.orthographicScale > 20 {
            camera.camera?.orthographicScale = 20
            zoomOutButton.enabled = false
        }
        zoomInButton.enabled = true
    }
    
    @IBAction func setRoomSizeButtonTapped(sender: UIButton) {
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        roomWidth = (numberFormatter.numberFromString(roomWidthTextField.text!)?.floatValue)!
        roomLength = (numberFormatter.numberFromString(roomLengthTextField.text!)?.floatValue)!
        
        if roomWidth <= 0.01 {
            roomWidth = 5.0
            roomWidthTextField.text = NSString(format: "%.2f", roomWidth)
                as String
            return
        }

        if roomLength <= 0.01 {
            roomLength = 10.0
            roomLengthTextField.text = NSString(format: "%.2f", roomLength)
                as String
            return
        }
        
        NSUserDefaults.standardUserDefaults().setFloat(roomWidth, forKey: RoomWidthKey)
        NSUserDefaults.standardUserDefaults().setFloat(roomLength, forKey: RoomLengthKey)
        
        setRoomStructure((CGFloat)(roomWidth), z: (CGFloat)(roomLength))
        
    }
    
    func disableAllButtons() {
        translateButton.enabled = false
        rotateButton.enabled = false
        completeButton.enabled = false
        deleteButton.enabled = false
    }
    
    func saveDesign() {
        self.myDesign = [NodeInfo]()
        for node in dynamicGeometry.childNodes {
            myDesign.append(NodeInfo(_node: node))
        }
        NSKeyedArchiver.archiveRootObject(self.myDesign, toFile: designFilePath)
    }
    
    func setRoomStructure(x: CGFloat, z: CGFloat) {
        
        // Constructing basic structure
        let leftWallGeometry = SCNBox(width: Constants.WallThickness, height: Constants.RoomYLength, length: z, chamferRadius: 0.0)
        leftWallGeometry.firstMaterial!.diffuse.contents = UIColor.lightGrayColor()
        leftWallNode.geometry = leftWallGeometry
        leftWallNode.position = SCNVector3Make(-Float(x) / 2.0, Float(Constants.RoomYLength) / 2.0, 0)
        
        let rightWallGeometry = SCNBox(width: Constants.WallThickness, height: Constants.RoomYLength, length: z, chamferRadius: 0.0)
        rightWallGeometry.firstMaterial!.diffuse.contents = UIColor.lightGrayColor()
        rightWallNode.geometry = rightWallGeometry
        rightWallNode.position = SCNVector3Make(Float(x) / 2.0, Float(Constants.RoomYLength) / 2.0, 0)
        
        let floorGeometry = SCNBox(width: x, height: Constants.WallThickness, length: z, chamferRadius: 0.0)
        floorGeometry.firstMaterial!.diffuse.contents = UIColor.lightGrayColor()
        floorNode.geometry = floorGeometry
        floorNode.position = SCNVector3Make(0, -Float(Constants.WallThickness) / 2.0, 0)
        
        let frontGeometry = SCNBox(width: x, height: Constants.RoomYLength, length: Constants.WallThickness, chamferRadius: 0.0)
        frontGeometry.firstMaterial!.diffuse.contents = UIColor.lightGrayColor()
        frontNode.geometry = frontGeometry
        frontNode.position = SCNVector3Make(0, Float(Constants.RoomYLength) / 2.0, -Float(z) / 2.0)
        
        let backGeometry = SCNBox(width: x, height: Constants.RoomYLength, length: Constants.WallThickness, chamferRadius: 0.0)
        backGeometry.firstMaterial!.diffuse.contents = UIColor.lightGrayColor()
        backNode.geometry = backGeometry
        backNode.position = SCNVector3Make(0, Float(Constants.RoomYLength) / 2.0, Float(z) / 2.0)
        
    }
    
    func sceneSetup () {
        
        setRoomStructure((CGFloat)(roomWidth), z: (CGFloat)(roomLength))
        staticGeometry.addChildNode(leftWallNode)
        staticGeometry.addChildNode(rightWallNode)
        staticGeometry.addChildNode(floorNode)
        staticGeometry.addChildNode(frontNode)
        staticGeometry.addChildNode(backNode)
        
        //debugLoadModelFromJSON()
        //debugLoadModelFromDae()
        
        geometryNode.addChildNode(staticGeometry)
        geometryNode.addChildNode(dynamicGeometry)
        scene.rootNode.addChildNode(geometryNode)
        
        camera.camera = SCNCamera()
        camera.camera!.usesOrthographicProjection = true
        camera.camera!.orthographicScale = 8
        camera.camera!.zNear = 0;
        camera.camera!.zFar = 200;
        camera.position = SCNVector3Make(0, 0, 50)
        cameraOrbit.addChildNode(camera)
        scene.rootNode.addChildNode(cameraOrbit)
        
        for nodeInfo in myDesign {
            dynamicGeometry.addChildNode(nodeInfo.node)
        }
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "panGesture:")
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        
        sceneView.addGestureRecognizer(panRecognizer)
        sceneView.addGestureRecognizer(tapGesture)
        sceneView.addGestureRecognizer(pinchGesture)
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.scene = scene
    }
    
    func handlePinch(sender: UIPinchGestureRecognizer) {
        switch state {
        case .Normal:
            break
        case .Translate:
            selectedNode.position.y = selectedNode.position.y + Float(sender.scale) / 20.0 * Float(sender.velocity)
        default:
            return
        }
    }
    
    func panGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(sender.view!)
        
        switch state {
        case .Normal:
            
            // Rotate camera around global X axis
            var newCameraXRot = cameraXRot
            newCameraXRot -= (Float)(translation.y)*(Float)(M_PI)/180.0
            if newCameraXRot > 0 {
                newCameraXRot = 0
            } else if newCameraXRot < -(Float)(M_PI_2) {
                newCameraXRot = -(Float)(M_PI_2)
            }
            cameraOrbit.rotation = SCNVector4Make(1, 0, 0, newCameraXRot)
            
            // Rotate geometryNode arount its Y axis
            var newGeoZRot = geoZRot
            newGeoZRot += (Float)(translation.x)*(Float)(M_PI)/180.0
            geometryNode.rotation = SCNVector4Make(0, 1, 0, newGeoZRot)
            
            if(sender.state == UIGestureRecognizerState.Ended) {
                cameraXRot = newCameraXRot
                geoZRot = newGeoZRot
            }
            
        case .Translate:
            let p = sender.locationInView(sceneView)
            let hitResults = sceneView.hitTest(p, options: [SCNHitTestRootNodeKey: staticGeometry])
            
            if hitResults.count > 0 {
                
                let result: SCNHitTestResult = hitResults[0]
                let node = result.node
                
                if node == floorNode {
                    
                    let hitLocation = result.worldCoordinates
                    selectedNode.position = SCNVector3Make(hitLocation.x, selectedNode.position.y, hitLocation.z)
                }
            }
            
        case .Rotate:
            let deltaAngle = (Float)(translation.x)*(Float)(M_PI)/180.0 / 3.0
            selectedNode.eulerAngles.y = selectedNode.eulerAngles.y + deltaAngle
        }
        
    }
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        self.view.endEditing(true)
        
        switch state {
        case .Normal:
            let p = gestureRecognize.locationInView(sceneView)
            let hitResults = sceneView.hitTest(p, options: nil)

            if hitResults.count > 0 {
                let result: AnyObject! = hitResults[0]
                guard let node = result.node else {
                    return
                }
                
                if node.parentNode == dynamicGeometry {
                    state = .Translate
                    selectNode(node)
                }
            }
            
        case .Translate:
            break
        case .Rotate:
            break
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
    
        let indexData = NSData(bytes: indices, length: sizeof(Int)*indices.count)
    
        let source = SCNGeometrySource(data: positionData, semantic:
                SCNGeometrySourceSemanticVertex, vectorCount: indices.count, floatComponents: true, componentsPerVector: 3, bytesPerComponent: sizeof(Float32), dataOffset: 0, dataStride: sizeof(Float32)*3)
    
        let element = SCNGeometryElement(data: indexData, primitiveType: SCNGeometryPrimitiveType.Triangles, primitiveCount: indices.count / 3, bytesPerIndex: sizeof(Int))

        let modelGeometry = SCNGeometry(sources: [source], elements: [element])
        return SCNNode(geometry: modelGeometry)
    }
    
    func debugLoadModelFromJSON() {
        let location = NSString(string:"/Users/shapeare/Documents/misc_chair01.js").stringByExpandingTildeInPath
        let rawData = NSData(contentsOfFile: location)
        let modelData = try? NSJSONSerialization.JSONObjectWithData(rawData!, options: NSJSONReadingOptions.AllowFragments)
        
        let modelNode = modelFromJson(modelData as! NSDictionary)
        
        modelNode.position = SCNVector3Make(0, 0, -3)
        scene.rootNode.addChildNode(modelNode)
    }
    
    func debugLoadModelFromDae() {
    
        let modelScene = SCNScene(named: "misc_chair01.dae")
        for child : AnyObject in modelScene!.rootNode.childNodes {
            let node = child as! SCNNode
            node.position = SCNVector3Make(0, 0, -4)
            dynamicGeometry.addChildNode(node)
        }

    }
    
    func selectNode(node: SCNNode) {
        selectedNode = node
        
        translateButton.enabled = false
        deleteButton.enabled = true
        rotateButton.enabled = true
        completeButton.enabled = true
    }
    
}

extension HomeViewController: FurnitureViewControllerDelegate {
    
    func pickFurniture(controller: FurnitureViewController, didPickFurniture modelData: NSData?) {
        let sceneSource = SCNSceneSource(data: modelData!, options: nil)
        var modelScene: SCNScene? = nil
        
        do {
            modelScene = try sceneSource?.sceneWithOptions(nil)
        } catch {
            return
        }
        
        for child : AnyObject in modelScene!.rootNode.childNodes {
            let node = child as! SCNNode
            node.position = SCNVector3Make(0, 0, 0)
            state = .Translate
            selectNode(node)
            dynamicGeometry.addChildNode(node)
        }
    }
}
