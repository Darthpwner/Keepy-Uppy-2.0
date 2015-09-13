//
//  Ball.swift
//  Keepy Uppy
//
//  Created by Matthew Allen Lin on 9/3/15.
//  Copyright (c) 2015 Matthew Allen Lin. All rights reserved.
//

import SpriteKit

let NumberOfBalls: UInt32 = 3

enum BallType: Int, Printable {
    case Basketball = 0, BeachBall, BowlingBall
    
    var description: String {
        switch self {
        case .Basketball:
            return "Basketball.png"
        case .BeachBall:
            return "Beach Ball.png"
        case .BowlingBall:
            return "Bowling Ball.png"
        }
    }
}

//Worry about this later
public class Ball {
    var mass: CGFloat
    var friction: CGFloat
    var restitution: CGFloat
    
    init(mass: CGFloat, friction: CGFloat, restitution: CGFloat) {
        self.mass = mass
        self.friction = friction
        self.restitution = restitution
    }
}