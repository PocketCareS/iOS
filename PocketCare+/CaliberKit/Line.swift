/*
Copyright 2020 University at Buffalo

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import SceneKit
import ARKit

enum DistanceUnit {
    case centimeter
    case inch
    case meter
    
    var fator: Float {
        switch self {
        case .centimeter:
            return 100.0
        case .inch:
            return 39.3700787
        case .meter:
            return 1.0
        }
    }
    
    var unit: String {
        switch self {
        case .centimeter:
            return "cm"
        case .inch:
            return "inch"
        case .meter:
            return "m"
        }
    }
    
    var title: String {
        switch self {
        case .centimeter:
            return "Centimeter"
        case .inch:
            return "Inch"
        case .meter:
            return "Meter"
        }
    }
}

final class Line {
    fileprivate var color: UIColor = .white
    
    fileprivate var startNode: SCNNode!
    fileprivate var endNode: SCNNode!
    fileprivate var text: SCNText!
    fileprivate var textNode: SCNNode!
    fileprivate var lineNode: SCNNode?
    
    fileprivate let sceneView: ARSCNView!
    fileprivate let startVector: SCNVector3!
    fileprivate let unit: DistanceUnit!
    
    init(sceneView: ARSCNView, startVector: SCNVector3, unit: DistanceUnit) {
        self.sceneView = sceneView
        self.startVector = startVector
        self.unit = unit
        
        let dot = SCNSphere(radius: 0.5)
        dot.firstMaterial?.diffuse.contents = color
        dot.firstMaterial?.lightingModel = .constant
        dot.firstMaterial?.isDoubleSided = true
        startNode = SCNNode(geometry: dot)
        startNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        startNode.position = startVector
        sceneView.scene.rootNode.addChildNode(startNode)
        
        endNode = SCNNode(geometry: dot)
        endNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        
        text = SCNText(string: "", extrusionDepth: 0.1)
        text.font = .systemFont(ofSize: 5)
        text.firstMaterial?.diffuse.contents = color
        text.alignmentMode  = CATextLayerAlignmentMode.center.rawValue
        text.truncationMode = CATextLayerTruncationMode.middle.rawValue
        text.firstMaterial?.isDoubleSided = true
        
        let textWrapperNode = SCNNode(geometry: text)
        textWrapperNode.eulerAngles = SCNVector3Make(0, .pi, 0)
        textWrapperNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        
        textNode = SCNNode()
        textNode.addChildNode(textWrapperNode)
        let constraint = SCNLookAtConstraint(target: sceneView.pointOfView)
        constraint.isGimbalLockEnabled = true
        textNode.constraints = [constraint]
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    func update(to vector: SCNVector3) {
        lineNode?.removeFromParentNode()
        lineNode = startVector.line(to: vector, color: color)
        sceneView.scene.rootNode.addChildNode(lineNode!)
        
        text.string = distance(to: vector)
        textNode.position = SCNVector3((startVector.x+vector.x)/2.0, (startVector.y+vector.y)/2.0, (startVector.z+vector.z)/2.0)
        
        endNode.position = vector
        if endNode.parent == nil {
            sceneView?.scene.rootNode.addChildNode(endNode)
        }
    }
    
    func distance(to vector: SCNVector3) -> String {
        return String(format: "%.2f%@", startVector.distance(from: vector) * unit.fator, unit.unit)
    }
    
    func distanceNumeric (to vector: SCNVector3) -> Float {
        return startVector.distance(from: vector)
    }
    
    func removeFromParentNode() {
        startNode.removeFromParentNode()
        lineNode?.removeFromParentNode()
        endNode.removeFromParentNode()
        textNode.removeFromParentNode()
    }
}
