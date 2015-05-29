//
//  ViewController.swift
//  Towers Of Hanoi
//
//  Created by Silviu Pop on 10/23/14.
//  Copyright (c) 2014 We Heart Swift. All rights reserved.
//

import UIKit
import SceneKit

class ViewController: UIViewController, SCNSceneRendererDelegate {
    var scene: HanoiScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scnView = self.view as! SCNView
        scene = HanoiScene() as HanoiScene
        scnView.scene = scene
        
        scnView.backgroundColor = UIColor.blackColor()
        
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = true
        
        scnView.play(nil)
    }
}

