//
//  ChooseBall.swift
//  Keepy Uppy
//
//  Created by Matthew Allen Lin on 9/3/15.
//  Copyright (c) 2015 Matthew Allen Lin. All rights reserved.
//

import UIKit

class ChooseBall: UIViewController {
    
    var ballType: BallType?
    
    class var sharedInstance: ChooseBall {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: ChooseBall? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = ChooseBall()
        }
        return Static.instance!
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func chooseBeachBall(sender: UIButton) {
        ballType = BallType.BeachBall
    }
    
    @IBAction func chooseBasketball(sender: UIButton) {
         ballType = BallType.Basketball
    }
    
    @IBAction func chooseBowlingBall(sender: UIButton) {
        ballType = BallType.BowlingBall
        println(ballType)
    }
}