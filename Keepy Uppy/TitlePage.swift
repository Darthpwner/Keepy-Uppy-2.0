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
    
    let playStartSong = PlayStartSong.sharedInstance
    
    override func viewDidLoad() {
  
        //Add the bouncing ball GIF
        var strImg: String = "http://www.platformtennis.org/Assets/Assets/images/Bouncing+Ball+Yellow.gif"
        animateGif(strImg)
        
        super.viewDidLoad()
        
        //Plays start song
        playStartSong.prepareAudios()
        playStartSong.song.play()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func animateGif(strImg: String) -> Void {
        var url: NSURL = NSURL(string: strImg)!
        
        animation.image = UIImage.animatedImageWithAnimatedGIFURL(url)
    }
}
