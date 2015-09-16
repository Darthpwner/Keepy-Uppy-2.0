//
//  PlayStartSong.swift
//  Keepy Uppy
//
//  Created by Matthew Allen Lin on 9/5/15.
//  Copyright (c) 2015 Matthew Allen Lin. All rights reserved.
//

import Foundation   //Needed for dispatch_once_t
import AVFoundation //Needed to play sounds

//Singleton
class PlayStartSong {
    
    var song: AVAudioPlayer = AVAudioPlayer()
    var songStarted: Bool = false
    
    class var sharedInstance: PlayStartSong {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: PlayStartSong? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = PlayStartSong()
        }
        return Static.instance!
    }
    
    func prepareAudios() {
        
        var path = NSBundle.mainBundle().pathForResource("start", ofType: "mp3")
        song = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: path!), error: nil)
        song.prepareToPlay()
        
        song.numberOfLoops = -1 //Makes the song play repeatedly
    }
}