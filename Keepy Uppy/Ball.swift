//
//  Ball.swift
//  Keepy Uppy
//
//  Created by Matthew Allen Lin on 9/3/15.
//  Copyright (c) 2015 Matthew Allen Lin. All rights reserved.
//

import SpriteKit

let NumerOfBalls: UInt32 = 4

enum BallType: Int, Printable {
    case Basketball = 0, BeachBall, BowlingBall
    
    var description: String {
        switch self {
        case .Basketball:
            return "Basketball.jpg"
        case .BeachBall:
            return "Beach Ball.jpg"
        case .BowlingBall:
            return "Bowling Ball.jpg"
        }
    }
}

class Ball {
    var mass: CGFloat
    var friction: CGFloat
    var restitution: CGFloat
    
    init(mass: CGFloat, friction: CGFloat, restitution: CGFloat) {
        self.mass = mass
        self.friction = friction
        self.restitution = restitution
    }
}