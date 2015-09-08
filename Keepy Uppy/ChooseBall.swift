//
//  ChooseBall.swift
//  Keepy Uppy
//
//  Created by Matthew Allen Lin on 9/3/15.
//  Copyright (c) 2015 Matthew Allen Lin. All rights reserved.
//

import UIKit

class ChooseBall: UIViewController {
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func chooseBeachBall(sender: UIButton) {
        BallType.BeachBall
    }
    
    @IBAction func chooseBasketball(sender: UIButton) {
        BallType.Basketball
    }
    
    @IBAction func chooseBowlingBall(sender: UIButton) {
        BallType.BowlingBall
    }
}