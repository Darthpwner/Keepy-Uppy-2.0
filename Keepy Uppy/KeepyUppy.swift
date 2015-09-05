//
//  KeepyUppy.swift
//  Keepy Uppy
//
//  Created by Matthew Allen Lin on 9/5/15.
//  Copyright (c) 2015 Matthew Allen Lin. All rights reserved.
//

let PointsPerHit = 1

protocol KeepyUppyDelegate {
    //Invoked when the player loses all 3 lives
    func gameDidEnd(keepyUppy: KeepyUppy)
    
    //Invoked when the player begins the game
    func gameDidBegin(KeepyUppy: KeepyUppy)
}

class KeepyUppy {
    var score: Int
    var lives: Int
    
    init() {
        score = 0
        lives = 3
    }
    
    //Tap anywhere on the screen to begin the game
    func beginGame() {
        //TODO
    }
    
    func ballHitGround() -> Bool {
        //if the ball hits the ground, return true
            //TODO
        return false
    }
    
    //Let the user know that the game did end
    func endGame() {
        //TODO
    }
}