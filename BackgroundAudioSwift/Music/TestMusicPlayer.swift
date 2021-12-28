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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(TestMusicPlayer.audioSessionInterrupted(_:)),
                                               name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            let _ = try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print("an error occurred when audio session category.\n \(error)")
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
    
    func playSongWithId(_ songId:NSNumber, title:String, artist:String) {
        MusicQuery().queryForSongWithId(songId, completionHandler: {[weak self] (result:MPMediaItem?) -> Void in
            if let nonNilResult = result {
                if let assetUrl = nonNilResult.value(forProperty:MPMediaItemPropertyAssetURL) as? URL {
                    let avSongItem = AVPlayerItem(url: assetUrl)
                    self!.avQueuePlayer.insert(avSongItem, after: nil)
                    self!.play()
                    //display now playing info on control center
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: title, MPMediaItemPropertyArtist: artist]
                } else {
                    print("assetURL for song \(songId) does not exist")
                }
            }
        })
        
    }
    
    func songIsAvailable(songId:NSNumber, completion:((Bool)->Void)? = nil)
    {
        MusicQuery().queryForSongWithId(songId, completionHandler: {(result:MPMediaItem?) -> Void in
            if let nonNilResult = result {
                if let _ = nonNilResult.value(forProperty:MPMediaItemPropertyAssetURL) as? URL {
                    completion?(true)
                } else {
                    completion?(false)
                }
            }
        })
    }

    
    //MARK: - Notifications
    @objc class func audioSessionInterrupted(_ notification:Notification)
    {
        print("interruption received: \(notification)")
    }
    
    //response to remote control events
    
    func remoteControlReceivedWithEvent(_ receivedEvent:UIEvent)  {
        if (receivedEvent.type == .remoteControl) {
            switch receivedEvent.subtype {
            case .remoteControlTogglePlayPause:
                if avQueuePlayer.rate > 0.0 {
                    pause()
                } else {
                    play()
                }
            case .remoteControlPlay:
                play()
            case .remoteControlPause:
                pause()
            default:
                print("received sub type \(receivedEvent.subtype) Ignoring")
            }
        }
    }
    
    

}
