//
//  GetBackgroundType.swift
//  Keepy Uppy
//
//  Created by Matthew Allen Lin on 9/8/15.
//  Copyright (c) 2015 Matthew Allen Lin. All rights reserved.
//

import Foundation   ////Needed for dispatch_once_t

//Singleton
class GetBackgroundType {
    
    var backgroundType: BackgroundType?
    
    class var sharedInstance: GetBackgroundType {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: GetBackgroundType? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = GetBackgroundType()
        }
        return Static.instance!
    }
}