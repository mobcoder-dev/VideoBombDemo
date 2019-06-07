

import ARKit

extension ViewController: ARSCNViewDelegate {
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        // If light estimation is enabled, update the intensity of the model's lights and the environment map
        if let lightEstimate = session.currentFrame?.lightEstimate {
            sceneView.scene.enableEnvironmentMapWithIntensity(lightEstimate.ambientIntensity / 40, queue: updateQueue)
        } else {
            sceneView.scene.enableEnvironmentMapWithIntensity(40, queue: updateQueue)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if #available(iOS 12.0, *) {
            if let objectAnchor = anchor as? ARObjectAnchor {
                
                guard let cameraTransform = session.currentFrame?.camera.transform else { return }
                
                let x = objectAnchor.transform
                
                let positionVec =  float3(x: Float(x.columns.3.x), y: Float(x.columns.3.y), z: Float(x.columns.3.z))
                
                let object = ViewController.availableObjects.first
                
                self.addSceneView(cameraTransform: cameraTransform, position: positionVec, definition: object!)
            }
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    func addSceneView(cameraTransform:simd_float4x4,position:float3,definition:VirtualObjectDefinition){
        
        let object = VirtualObject(definition: definition)
        object.scale = SCNVector3(0.05, 0.05, 0.05)
        
        self.virtualObjectManager.loadVirtualObject(object, to: position, cameraTransform: cameraTransform)
        if object.parent == nil {
            self.sceneView.scene.rootNode.addChildNode(object)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
       
    }
}
