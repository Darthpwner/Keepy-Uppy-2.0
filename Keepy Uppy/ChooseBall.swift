//
//  ChooseBall.swift
//  Keepy Uppy
//
//  Created by Matthew Allen Lin on 9/3/15.
//  Copyright (c) 2015 Matthew Allen Lin. All rights reserved.
//

import UIKit

class ChooseBall: UIViewController {
    
    let getBallType = GetBallType.sharedInstance
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func chooseBeachBall(sender: UIButton) {
        getBallType.ballType = BallType.BeachBall
        println(getBallType.ballType)
    }
    
    @IBAction func chooseBasketball(sender: UIButton) {
         getBallType.ballType = BallType.Basketball
        println(getBallType.ballType)
    }
    
    @IBAction func chooseBowlingBall(sender: UIButton) {
        getBallType.ballType = BallType.BowlingBall
        println(getBallType.ballType)
    }
}