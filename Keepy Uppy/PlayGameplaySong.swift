//
//  PlayGameplaySong.swift
//  Keepy Uppy
//
//  Created by Matthew Allen Lin on 9/12/15.
//  Copyright (c) 2015 Matthew Allen Lin. All rights reserved.
//

import Foundation   //Needed for dispatch_once_t
import AVFoundation //Needed to play sounds

//Singleton
class PlayGameplaySong {
    
    var song: AVAudioPlayer = AVAudioPlayer()
    
    class var sharedInstance: PlayGameplaySong {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: PlayGameplaySong? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = PlayGameplaySong()
        }
        return Static.instance!
    }
    
    func prepareAudios() {
        
        var path = NSBundle.mainBundle().pathForResource("gameplay-2.0", ofType: "mp3")
        song = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: path!), error: nil)
        song.prepareToPlay()
        
        song.numberOfLoops = -1 //Makes the song play repeatedly
    }
}
