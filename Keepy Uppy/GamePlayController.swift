//
//  GamePlayController.swift
//  Keepy Uppy
//
//  Created by Matthew Allen Lin on 9/3/15.
//  Copyright (c) 2015 Matthew Allen Lin. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GamePlayController: UIViewController {
    var lives: Int = 3
    
    var scene: GameScene!
    var song: AVAudioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        // Present the scene.
        skView.presentScene(scene)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func prepareAudios() {
        
        var path = NSBundle.mainBundle().pathForResource("gameplay", ofType: "mp3")
        song = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: path!), error: nil)
        song.prepareToPlay()
        
        song.numberOfLoops = -1 //Makes the song play repeatedly
    }
    
    //UITouchGesture Functions
    
    //Gameplay Functions
    func gameDidBegin() {
        
    }
    
    func gameDidEnd() -> Bool {
        if(lives == 0) {
            view.userInteractionEnabled = false
            scene.playSound("gameover.mp3")
            return true
        }
        return false
    }
}
