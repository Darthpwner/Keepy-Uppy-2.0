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
    
    @IBAction func unwindToContainerVC(segue: UIStoryboardSegue) {
        if scene.gameEnded == true {
            println(self.navigationController)
            navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    @IBAction func onTapped(sender: AnyObject) {
        if scene.gameEnded == true {
            self.navigationController?.popToRootViewControllerAnimated(true)
            
            //Play song?
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    let playGameplaySong = PlayGameplaySong.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("onTapped:"))
        skView.addGestureRecognizer(tapRecognizer)
        
        //Plays gameplay song
        playGameplaySong.prepareAudios()
        playGameplaySong.song.play()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true 
    }
}
