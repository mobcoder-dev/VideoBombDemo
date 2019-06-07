//
//  AppDelegate.swift
//  VideoBombDemo
//
//  Created by Rohit Pathak on 07/05/19.
//  Copyright © 2019 Rohit Pathak. All rights reserved.
//

import ARKit
import SceneKit
import UIKit
import AVKit
import Photos

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    var virtualObjectManager: VirtualObjectManager!

    /// The view controller that displays the status and "restart experience" UI.
    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    
    /// A serial queue for thread safety when modifying the SceneKit node graph.
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    var recorder: SceneKitVideoRecorder?

    
    static let availableObjects: [VirtualObjectDefinition] = {
        guard let jsonURL = Bundle.main.url(forResource: "VirtualObjects", withExtension: "json") else {
            fatalError("Missing 'VirtualObjects.json' in bundle.")
        }
        
        do {
            let jsonData = try Data(contentsOf: jsonURL)
            return try JSONDecoder().decode([VirtualObjectDefinition].self, from: jsonData)
        } catch {
            fatalError("Unable to decode VirtualObjects JSON: \(error)")
        }
    }()
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Synchronize updates via the `serialQueue`.
        virtualObjectManager = VirtualObjectManager(updateQueue: updateQueue)
        
        sceneView.setup()
        sceneView.delegate = self
        sceneView.session = session
        sceneView.showsStatistics = true
        
        sceneView.scene.enableEnvironmentMapWithIntensity(25, queue: updateQueue)

        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if recorder == nil {
            var options = SceneKitVideoRecorder.Options.default
            let scale = UIScreen.main.nativeScale
            let sceneSize = sceneView.bounds.size
            options.videoSize = CGSize(width: sceneSize.width * scale, height: sceneSize.height * scale)
            recorder = try! SceneKitVideoRecorder(withARSCNView: sceneView, options: options)
        }
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		UIApplication.shared.isIdleTimerDisabled = true

        // Start the AR experience
        resetObjectTracking()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
        session.pause()
	}

    @IBAction func startRecording (sender: UIButton) {
        self.recorder?.startWriting().onSuccess {
            print("Recording Started")
        }
    }
    
    @IBAction func stopRecording (sender: UIButton) {
        self.recorder?.finishWriting().onSuccess { [weak self] url in
            print("Recording Finished", url)
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                
            }) { saved, error in
                if saved, let sself = self{
                    sself.showPlayerConrtoller(url: url)
                }
            }
        }
    }
    
    fileprivate func showPlayerConrtoller(url:URL){
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    // MARK: - Session management (Image detection setup)
    
    /// Prevents restarting the session while a restart is in progress.
    var isRestartAvailable = true

    /// Creates a new AR configuration to run on the `session`.
    /// - Tag: ARReferenceImage-Loading
	func resetTracking() {
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        statusViewController.scheduleMessage("Look around to detect images", inSeconds: 7.5, messageType: .contentPlacement)
	}

    func resetObjectTracking(){
        
        let configuration = ARWorldTrackingConfiguration()
        if #available(iOS 12.0, *) {
            guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: "AR Resources-Object", bundle: nil) else {
                fatalError("Missing expected asset catalog resources.")
            }
            configuration.detectionObjects = referenceObjects
            session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        } else {
            // Fallback on earlier versions
        }
        
        statusViewController.scheduleMessage("Look around to detect objects", inSeconds: 7.5, messageType: .contentPlacement)

    }
    

    // MARK: - Gesture Recognizers
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        virtualObjectManager.reactToTouchesBegan(touches, with: event, in: self.sceneView)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        virtualObjectManager.reactToTouchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if virtualObjectManager.virtualObjects.isEmpty {
            return
        }
        virtualObjectManager.reactToTouchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        virtualObjectManager.reactToTouchesCancelled(touches, with: event)
    }

}
