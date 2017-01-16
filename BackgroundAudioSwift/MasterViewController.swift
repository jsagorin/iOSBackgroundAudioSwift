//
//  MasterViewController.swift
//  BackgroundAudioSwift
//
//  Created by Jonathan Sagorin on 3/5/2015.
//
//

import UIKit
import MediaPlayer

class MasterViewController: UITableViewController {
    
    var artists = [NSDictionary]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestAuth()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let artistAlbum = artists[indexPath.section] as NSDictionary
                (segue.destination as! DetailViewController).songIndex = indexPath.row
                (segue.destination as! DetailViewController).artistAlbum = artistAlbum
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return artists.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if artists.count > 0 {
            let artistAlbum = artists[section] as NSDictionary
            if let songs = artistAlbum["songs"] as? [NSDictionary] {
                return songs.count
            }
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        let artistAlbum:NSDictionary = artists[indexPath.section] as NSDictionary
        if let songs = artistAlbum["songs"] as? [NSDictionary] {
            let song = songs[indexPath.row]
            tableViewCell.textLabel?.text = song["title"] as? String
            tableViewCell.detailTextLabel?.text = artistAlbum["album"] as? String
        }
        
        return tableViewCell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let artistAlbum:NSDictionary = artists[section] as NSDictionary
        return artistAlbum["artist"] as? String
    }
    
    //MARK: - Helper methods
    
    fileprivate func requestAuth() {
        
        MPMediaLibrary.requestAuthorization { (authStatus) in
            switch authStatus {
            case .notDetermined:
                self.requestAuth()
                break
            case .authorized:
                self.querySongs()
                break
            default:
                self.displayPermissionsError()
                break
                
            }
        }
    }
    
    fileprivate func querySongs() {
        
        title = "Querying..."
        MusicQuery().queryForSongs {(result:NSDictionary?) in
            if let nonNilResult = result {
                artists = nonNilResult["artists"] as! [NSDictionary]
                let songCount = nonNilResult["songCount"] as! Int
                DispatchQueue.main.async {
                    self.title = "Songs (\(songCount))"
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    fileprivate func displayPermissionsError() {
        let alertVC = UIAlertController(title: "This is a demo", message: "Unauthorized or restricted access. Cannot play media. Fix in Settings?" , preferredStyle: .alert)
        
        //cancel
        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(settingsURL) {
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
            let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                UIApplication.shared.openURL(settingsURL)
            })
            alertVC.addAction(settingsAction)
        } else {
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
        }
        present(alertVC, animated: true, completion: nil)
    }
}

