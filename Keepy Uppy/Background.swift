//
//  Background.swift
//  Keepy Uppy
//
//  Created by Matthew Allen Lin on 9/8/15.
//  Copyright (c) 2015 Matthew Allen Lin. All rights reserved.
//

let NumberOfBackgrounds: UInt32 = 3

enum BackgroundType: Int, CustomStringConvertible {
    case Desert = 0, Beach, Forest
    
    var description: String {
        switch self {
        case .Desert:
            return "Desert Background.jpg"
        case .Beach:
            return "Beach Background.jpg"
        case .Forest:
            return "Forest Background.jpg"
        }
    }
}
