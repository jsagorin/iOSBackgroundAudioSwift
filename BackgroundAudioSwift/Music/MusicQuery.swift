//
//  MusicQuery.swift
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
import MediaPlayer

class MusicQuery: NSObject {
    
    /**
    Query for songs on the device (This query won't work in the simulator)
    
    :param: completionHandler closure block with result
    - Dictionary structure:
    - artists: array of dictionarys
    - songCount: total songs on the device
    
    */
    func queryForSongs(completionHandler:(result:NSDictionary) -> Void) {
        let query = MPMediaQuery.artistsQuery()
        let songsByArtist = query.collections as [MPMediaItemCollection]
        
        var songCount = 0
        var artists:[AnyObject] = [AnyObject]()
        var albumSortingDictionary:NSMutableDictionary = NSMutableDictionary()
        
        for album in songsByArtist {
            let albumSongs = album.items as [MPMediaItem]
            for songMediumItem in albumSongs {
                var artistName:String = songMediumItem.valueForProperty(MPMediaItemPropertyArtist) as? String ?? ""
                var albumName:String = songMediumItem.valueForProperty(MPMediaItemPropertyAlbumTitle) as? String ?? ""
                let songTitle:String = songMediumItem.valueForProperty(MPMediaItemPropertyTitle) as? String ?? ""
                let songId:NSNumber = songMediumItem.valueForProperty(MPMediaItemPropertyPersistentID) as NSNumber
                
                var artistAlbum = albumSortingDictionary.objectForKey(albumName) as? NSDictionary
                if (artistAlbum == nil) {
                    artistAlbum = NSDictionary(objects: [artistName,albumName,NSMutableArray()], forKeys: ["artist","album","songs"])
                    albumSortingDictionary[albumName] = artistAlbum
                }
                
                var songs:NSMutableArray = artistAlbum!["songs"] as NSMutableArray
                let song:NSDictionary = ["title":songTitle, "songId":songId]
                songs.addObject(song)
                songCount++
            }
            
            
            //sort by AlbumName
            let sortedAlbumsByName = albumSortingDictionary.keysSortedByValueUsingComparator { (obj1:AnyObject! , obj2:AnyObject!) -> NSComparisonResult in
                let one = obj1 as NSDictionary
                let two = obj2 as NSDictionary
                return (one["album"] as String).localizedCaseInsensitiveCompare((two["album"] as String))
            }
            
            for album in sortedAlbumsByName {
                let artistAlbum: AnyObject? = albumSortingDictionary[(album as String)]
                artists.append(artistAlbum!)
            }
            
            albumSortingDictionary.removeAllObjects()
        }
        
        completionHandler(result: NSDictionary(objects: [artists, songCount], forKeys: ["artists", "songCount"]))
        
    }
    
    /**
    Query for a particular song
    
    :param: songId            the songPerstistenceId
    :param: completionHandler MPMediaItem single instance
    */
    func queryForSongWithId(songId:NSNumber, completionHandler:(result:MPMediaItem?) -> Void) {
        let mediaItemPersistenceIdPredicate:MPMediaPropertyPredicate =
        MPMediaPropertyPredicate(value: songId, forProperty: MPMediaItemPropertyPersistentID)
        let songQuery = MPMediaQuery(filterPredicates: NSSet(object: mediaItemPersistenceIdPredicate))
        completionHandler(result: songQuery.items.last as? MPMediaItem)
    }
    
    
    
}
