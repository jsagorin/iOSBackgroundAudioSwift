//
//  TestMusicPlayer.swift
//  BackgroundAudioSwift
//
//  Created by Jonathan Sagorin on 3/5/2015.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

//

import UIKit

import AVFoundation
import MediaPlayer
class TestMusicPlayer: NSObject {
 
    let avQueuePlayer:AVQueuePlayer = AVQueuePlayer()
    
    /**
    Initialises the audio session
    */
    class func initSession() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioSessionInterrupted:", name: AVAudioSessionInterruptionNotification, object: AVAudioSession.sharedInstance())
        var error:NSError?

        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: &error)
        
        if let nonNilError = error {
            println("an error occurred when audio session category.\n \(error)")
        }
        
        var activationError:NSError?
        let success = AVAudioSession.sharedInstance().setActive(true, error: &activationError)
        if !success {
            if let nonNilActivationError = activationError {
                println("an error occurred when audio session category.\n \(nonNilActivationError)")
            } else {
                println("audio session could not be activated")
            }
        }
    }
    
    /**
    Pause music
    */
    func pause() {
        avQueuePlayer.pause()
    }
    
    /**
    Play music
    */
    func play() {
        avQueuePlayer.play()
    }
    
    func playSongWithId(songId:NSNumber, title:String, artist:String) {
        MusicQuery().queryForSongWithId(songId, completionHandler: {[weak self] (result:MPMediaItem?) -> Void in
            if let nonNilResult = result {
                let assetUrl:NSURL = nonNilResult.valueForProperty(MPMediaItemPropertyAssetURL) as NSURL
                let avSongItem = AVPlayerItem(URL: assetUrl)
                self!.avQueuePlayer.insertItem(avSongItem, afterItem: nil)
                self!.play()
                //display now playing info on control center
                MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyTitle: title, MPMediaItemPropertyArtist: artist]
            }
        })
        
    }
    
    //MARK: - Notifications
    func audioSessionInterrupted(notification:NSNotification)
    {
        println("interruption received: \(notification)")
    }
    
    //response to remote control events
    
    func remoteControlReceivedWithEvent(receivedEvent:UIEvent)  {
        if (receivedEvent.type == .RemoteControl) {
            switch receivedEvent.subtype {
            case .RemoteControlTogglePlayPause:
                if avQueuePlayer.rate > 0.0 {
                    pause()
                } else {
                    play()
                }
            case .RemoteControlPlay:
                play()
            case .RemoteControlPause:
                pause()
            default:
                println("received sub type \(receivedEvent.subtype) Ignoring")
            }
        }
    }
    
    

}
