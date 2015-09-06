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
    
    override func viewDidLoad() {
        singleton.song.stop()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func chooseDesert(sender: UIButton) {
        //super.stopSong()
    }
    
    @IBAction func chooseBeach(sender: UIButton) {
        //super.stopSong()
    }
    
    @IBAction func chooseForest(sender: UIButton) {
        //super.stopSong()
    }
}