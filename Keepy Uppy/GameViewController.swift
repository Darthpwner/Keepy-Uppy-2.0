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
    
    var lives: Int = 3
    
    var song: AVAudioPlayer = AVAudioPlayer()

    //Clicks labels
    @IBOutlet weak var bestClicksLabel: UILabel!
    
    @IBOutlet weak var lastClicksLabel: UILabel!
    
    @IBOutlet weak var currentClicksLabel: UILabel!
        
    override func viewDidLoad() {
        println("SECOND")
        
        super.viewDidLoad()
        
        //I am not sure what the code below does
        
        //Configure the view.
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        //TEMPORARY
        skView.showsFPS = true
        skView.showsNodeCount = true
        ////////////////////////////
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        // Present the scene.
        skView.presentScene(scene)
        
        //Plays gameplay song
        prepareAudios()
        song.play()
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
    
    //Gameplay Functions
    func gameDidBegin() {
        
    }
    
    //If game ends, stop player interaction and the gameplay song
    func gameDidEnd() -> Bool {
        if(lives == 0) {
            view.userInteractionEnabled = false
            song.stop()
            scene.playSound("gameover.mp3")
            return true
        }
        return false
    }
}
