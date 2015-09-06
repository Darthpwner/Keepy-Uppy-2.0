//
//  ChooseBackground.swift
//  Keepy Uppy
//
//  Created by Matthew Allen Lin on 9/3/15.
//  Copyright (c) 2015 Matthew Allen Lin. All rights reserved.
//

import UIKit
import SpriteKit

class ChooseBackground: UIViewController {
    
    let singleton = PlayStartSong.sharedInstance
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    @IBAction func chooseDesert(sender: UIButton) {
        singleton.song.stop()
    }

    
    @IBAction func chooseBeach(sender: UIButton) {
        singleton.song.stop()
    }
    
    
    @IBAction func chooseForest(sender: UIButton) {
        singleton.song.stop()
    }
}