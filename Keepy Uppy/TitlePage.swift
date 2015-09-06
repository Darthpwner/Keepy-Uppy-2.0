//
//  TitlePage.swift
//  Keepy Uppy
//
//  Created by Matthew Allen Lin on 9/5/15.
//  Copyright (c) 2015 Matthew Allen Lin. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class TitlePage: UIViewController {
    
    var scene: GameScene!
    
    let singleton = PlayStartSong.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //I am not sure what the code below does
        
        // Configure the view.
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        // Present the scene.
        skView.presentScene(scene)
        
        //Plays start song
        singleton.prepareAudios()
        singleton.song.play()
        
        println("FIRST")
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
