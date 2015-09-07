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
    
    @IBOutlet weak var animation: UIImageView!
    
    var scene: GameScene!
    
    let singleton = PlayStartSong.sharedInstance
    
    //
//    @IBOutlet weak var ImageGIF: UIImageView!
//    
//    override func viewDidLoad() {
//        
//        //  http://www.kyst.no/ep_bilder/164/16863-ceabe11810360ac49045863747d2ca85-67b5126fe38caa1839cb3b35b903ef53storvikbanner.gif
//        
//        var strImg : String = "http://www.kyst.no/ep_bilder/164/16863-ceabe11810360ac49045863747d2ca85-67b5126fe38caa1839cb3b35b903ef53storvikbanner.gif"
//        
//        
//        var url: NSURL = NSURL(string: strImg)!
//        
//        ImageGIF.image = UIImage.animatedImageWithAnimatedGIFURL(url)
//        
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//    }
    //
    
    override func viewDidLoad() {
        //I am not sure what the code below does
        
        // Configure the view.
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        // Present the scene.
        skView.presentScene(scene)
        
        //Add the bouncing ball GIF
        var strImg: String = "http://www.platformtennis.org/Assets/Assets/images/Bouncing+Ball+Yellow.gif"
        
        var url: NSURL = NSURL(string: strImg)!
        
        animation.image = UIImage.animatedImageWithAnimatedGIFURL(url)
        
        super.viewDidLoad()
        
        //Plays start song
        singleton.prepareAudios()
        singleton.song.play()
        
        println("FIRST")
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
