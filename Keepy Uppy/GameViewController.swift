//
//  GameViewController.swift
//  Keepy Uppy
//
//  Created by Matthew Allen Lin on 9/3/15.
//  Copyright (c) 2015 Matthew Allen Lin. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var scene: GameScene!
    
    let playGameplaySong = PlayGameplaySong.sharedInstance

    override func viewDidLoad() {
        println("SECOND")
        
        super.viewDidLoad()
        
        //I am not sure what the code below does
        
        //Configure the view.
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        //TEMPORARY
        //skView.showsFPS = true
        skView.showsNodeCount = true
        ////////////////////////////
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill

        // Present the scene.
        skView.presentScene(scene)
        
        //Plays gameplay song
        playGameplaySong.prepareAudios()
        playGameplaySong.song.play()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
