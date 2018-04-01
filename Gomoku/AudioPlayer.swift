//
//  AudioPlayer.swift
//  Gobang
//
//  Created by Jiachen Ren on 12/31/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import Foundation
import AVFoundation

class AudioPlayer {
    private static var player: AVAudioPlayer?
    
    public static func playSound(name: String, ext: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType(rawValue: ext).rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else {
                return
            }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
