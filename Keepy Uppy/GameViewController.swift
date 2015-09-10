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
    
    var song: AVAudioPlayer = AVAudioPlayer()

    var score: Int = 0
    
    //Clicks labels
    @IBOutlet weak var scoreLabel: UILabel!
    
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
        
        scoreLabel.text = "\(score)"

        
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
}
