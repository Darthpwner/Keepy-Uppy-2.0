//
//  ChooseBall.swift
//  Keepy Uppy
//
//  Created by Matthew Allen Lin on 9/3/15.
//  Copyright (c) 2015 Matthew Allen Lin. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class ChooseBall: GameViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareAudios()
        song.play()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func chooseBeachBall(sender: UIButton) {
        song.pause()
    }
    
    @IBAction func chooseBasketball(sender: UIButton) {
        song.pause()
    }
    
    @IBAction func chooseBowlingBall(sender: UIButton) {
        song.pause()
    }
}