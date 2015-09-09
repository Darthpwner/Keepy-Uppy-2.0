//
//  GetBallType.swift
//  Keepy Uppy
//
//  Created by Matthew Allen Lin on 9/8/15.
//  Copyright (c) 2015 Matthew Allen Lin. All rights reserved.
//

import Foundation   //

class GetBallType {

    var ballType: BallType?

    class var sharedInstance: GetBallType {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: GetBallType? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = GetBallType()
        }
        return Static.instance!
    }
}