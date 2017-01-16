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
                let songId = song["songId"] as! NSNumber
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let nonNilArtistAlbum = artistAlbum {
            let song = (nonNilArtistAlbum["songs"] as! NSArray).object(at: songIndex) as! NSDictionary
            musicPlayer.playSongWithId(song["songId"] as! NSNumber, title:song["title"] as! String,
                                            artist:nonNilArtistAlbum["artist"] as! String)
            musicPlayer.songIsAvailable(songId: song["songId"] as! NSNumber, completion: { (available) in
                if available {
                    self.musicPlayer.playSongWithId(song["songId"] as! NSNumber, title:song["title"] as! String,
                                               artist:nonNilArtistAlbum["artist"] as! String)
                    UIApplication.shared.beginReceivingRemoteControlEvents()
                    self.becomeFirstResponder()
                } else {
                    let alertVC = UIAlertController(title:"Error", message:"Song is not available. It may not be downloaded", preferredStyle:.alert)
                    alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertVC, animated: true, completion: nil)
                }
            })
            
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    //MARK: - user actions
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        if (sender.titleLabel?.text == "Pause") {
            sender.setTitle("Play", for: UIControlState())
            musicPlayer.pause()
        } else {
            sender.setTitle("Pause", for: UIControlState())
            musicPlayer.play()
        }
    }

    //MARK: - events received from phone
    override func remoteControlReceived(with event: UIEvent?) {
        musicPlayer.remoteControlReceivedWithEvent(event!)
    }
    
    override var canBecomeFirstResponder : Bool {
        //allow this instance to receive remote control events
        return true
    }
}

