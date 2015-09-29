//
//  TitlePage.swift
//  Keepy Uppy
//
//  Created by Matthew Allen Lin on 9/5/15.
//  Copyright (c) 2015 Matthew Allen Lin. All rights reserved.
//

import UIKit

class TitlePage: UIViewController {
    
    @IBOutlet weak var animation: UIImageView!
    
    var scene: GameScene!
    
    override func viewDidLoad() {
        let playStartSong = PlayStartSong.sharedInstance    //Move the constant assignment in here to prevent reinstantiating
        
        //Add the bouncing ball GIF
        let strImg: String = "http://www.platformtennis.org/Assets/Assets/images/Bouncing+Ball+Yellow.gif"
        animateGif(strImg)
        
        super.viewDidLoad()
        
        //Plays start song
        if playStartSong.songStarted == false {
            playStartSong.prepareAudios()
            playStartSong.song.play()   //Keeps getting called
            playStartSong.songStarted = true
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func unwindToTitleViewController(segue: UIStoryboardSegue) {
        let source = segue.sourceViewController
        source.noteNptent
    }
    
    func animateGif(strImg: String) -> Void {
        let url: NSURL = NSURL(string: strImg)!
        
        animation.image = UIImage.animatedImageWithAnimatedGIFURL(url)
    }
}
