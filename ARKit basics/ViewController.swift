//
//  ViewController.swift
//  ARKit basics
//
//  Created by William Moody on 3/20/20.
//  Copyright © 2020 William Moody. All rights reserved.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arView.session.delegate = self
        
        setupARView()
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
    //MARK: setup methods
    //setting up a custom AR View
    func setupARView() {
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        //can also track body, face, images, some others
        configuration.planeDetection = [.horizontal, .vertical]
        //setting view flags
        configuration.environmentTexturing = .automatic
        //makes textures realistic - only supported on ios 12 on specific devices
        arView.session.run(configuration)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        //this func is turning a tapp on a screen into corrdinates in space
        let location = recognizer.location(in: arView)
        
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        //checking if the tap hit somthing
        
        if let firstResult = results.first {
            let anchor = ARAnchor(name: "toy_robot_vintage", transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
        } else {
            print("Object placement failed - couldn't find surface")
        }
    }
    
    func placeObject(named entityName: String, for anchor: ARAnchor) {
        let entity = try! ModelEntity.loadModel(named: entityName)
        
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation, .translation], for: entity)
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
    }
}

extension ViewController: ARSessionDelegate {
    //func runs when anchor is added
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "toy_robot_vintage" {
                placeObject(named: anchorName, for: anchor)
            }
        }
    }
}
