//
//  ChooseBackground.swift
//  Keepy Uppy
//
//  Created by Matthew Allen Lin on 9/3/15.
//  Copyright (c) 2015 Matthew Allen Lin. All rights reserved.
//

import UIKit

class ChooseBackground: UIViewController {
    
    let playStartSong = PlayStartSong.sharedInstance
    let getBackgroundType = GetBackgroundType.sharedInstance
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    @IBAction func chooseDesert(sender: UIButton) {
        playStartSong.song.stop()
        getBackgroundType.backgroundType = BackgroundType.Desert
    }

    
    @IBAction func chooseBeach(sender: UIButton) {
        playStartSong.song.stop()
        getBackgroundType.backgroundType = BackgroundType.Beach
    }
    
    
    @IBAction func chooseForest(sender: UIButton) {
        playStartSong.song.stop()
        getBackgroundType.backgroundType = BackgroundType.Forest
    }
}