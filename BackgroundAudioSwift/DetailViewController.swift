//
//  DetailViewController.swift
//  BackgroundAudioSwift
//
//  Created by Jonathan Sagorin on 3/5/2015.
//
//

import UIKit

class DetailViewController: UIViewController {

    var artistAlbum:NSDictionary?
    var songIndex:Int = 0
    var musicPlayer:TestMusicPlayer = TestMusicPlayer()

    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var songIdLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var playPausebutton: UIButton!
    
    func configureView() {
        if let nonNilArtistAlbum = artistAlbum {
            artistNameLabel.text = nonNilArtistAlbum["artist"] as? String
            albumNameLabel!.text = nonNilArtistAlbum["album"] as? String
            
            if let songs = nonNilArtistAlbum["songs"] as? [NSDictionary] {
                let song = songs[songIndex]
                songTitleLabel.text = song["title"] as? String
                let songId = song["songId"] as NSNumber
                songIdLabel.text = "\(songId)"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        TestMusicPlayer.initSession()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let nonNilArtistAlbum = artistAlbum {
            let song = (nonNilArtistAlbum["songs"] as NSArray).objectAtIndex(songIndex) as NSDictionary
            self.musicPlayer.playSongWithId(song["songId"] as NSNumber, title:song["title"] as String, artist:nonNilArtistAlbum["artist"] as String)
            
        }
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        becomeFirstResponder()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
    }
    //MARK: - user actions
    @IBAction func playPauseButtonTapped(sender: UIButton) {
        if (sender.titleLabel?.text == "Pause") {
            sender.setTitle("Play", forState: .Normal)
            musicPlayer.pause()
        } else {
            sender.setTitle("Pause", forState: .Normal)
            musicPlayer.play()
        }
    }

    //MARK: - events received from phone
    override func remoteControlReceivedWithEvent(event: UIEvent) {
        musicPlayer.remoteControlReceivedWithEvent(event)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        //allow this instance to receive remote control events
        return true
    }
}

