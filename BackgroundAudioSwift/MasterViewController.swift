//
//  MasterViewController.swift
//  BackgroundAudioSwift
//
//  Created by Jonathan Sagorin on 3/5/2015.
//
//

import UIKit

class MasterViewController: UITableViewController {

    var artists = [NSDictionary]()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        querySongs()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let artistAlbum = artists[indexPath.section] as NSDictionary
                (segue.destinationViewController as DetailViewController).songIndex = indexPath.row
                (segue.destinationViewController as DetailViewController).artistAlbum = artistAlbum
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return artists.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if artists.count > 0 {
            let artistAlbum = artists[section] as NSDictionary
            if let songs = artistAlbum["songs"] as? [NSDictionary] {
                return songs.count
            }
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let tableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let artistAlbum:NSDictionary = artists[indexPath.section] as NSDictionary
        if let songs = artistAlbum["songs"] as? [NSDictionary] {
            let song = songs[indexPath.row]
            tableViewCell.textLabel?.text = song["title"] as? String
            tableViewCell.detailTextLabel?.text = artistAlbum["album"] as? String
        }
        
        return tableViewCell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let artistAlbum:NSDictionary = artists[section] as NSDictionary
        return artistAlbum["artist"] as? String
    }

    //MARK: - Helper methods
    private func querySongs() {
        
        title = "Querying..."
        MusicQuery().queryForSongs {(result:NSDictionary?) in
            if let nonNilResult = result {
                self.artists = nonNilResult["artists"] as [NSDictionary]
                let songCount = nonNilResult["songCount"] as Int
                self.title = "Songs (\(songCount))"
                self.tableView.reloadData()
                
            }
        }
        
    }
}

