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
    func queryForSongs(_ completionHandler:(_ result:NSDictionary) -> Void) {
        let query = MPMediaQuery.artists()
        let songsByArtist = query.collections! as [MPMediaItemCollection]
        
        var songCount = 0
        var artists = [AnyObject]()
        let albumSortingDictionary:NSMutableDictionary = NSMutableDictionary()
        
        for album in songsByArtist {
            let albumSongs = album.items as [MPMediaItem]
            for songMediumItem in albumSongs {
                let artistName:String = songMediumItem.value(forProperty: MPMediaItemPropertyArtist) as? String ?? ""
                let albumName:String = songMediumItem.value(forProperty: MPMediaItemPropertyAlbumTitle) as? String ?? ""
                let songTitle:String = songMediumItem.value(forProperty: MPMediaItemPropertyTitle) as? String ?? ""
                let songId:NSNumber = songMediumItem.value(forProperty: MPMediaItemPropertyPersistentID) as! NSNumber
                
                var artistAlbum = albumSortingDictionary.object(forKey: albumName) as? NSDictionary
                if (artistAlbum == nil) {
                    artistAlbum = NSDictionary(objects: [artistName,albumName,NSMutableArray()], forKeys: ["artist" as NSCopying,"album" as NSCopying,"songs" as NSCopying])
                    albumSortingDictionary[albumName] = artistAlbum
                }
                
                let songs:NSMutableArray = artistAlbum!["songs"] as! NSMutableArray
                let song:NSDictionary = ["title":songTitle, "songId":songId]
                songs.add(song)
                songCount += 1
            }
            
            
            //sort by AlbumName
            let sortedAlbumsByName = albumSortingDictionary.keysSortedByValue(comparator: { (obj1:Any! , obj2:Any!) -> ComparisonResult in
                let one = obj1 as! NSDictionary
                let two = obj2 as! NSDictionary
                return (one["album"] as! String).localizedCaseInsensitiveCompare((two["album"] as! String))
            })
            
            for album in sortedAlbumsByName {
                let artistAlbum = albumSortingDictionary[(album as! String)]
                artists.append(artistAlbum as AnyObject)
            }
            
            albumSortingDictionary.removeAllObjects()
        }
        
        completionHandler(NSDictionary(objects: [artists, songCount], forKeys: ["artists" as NSCopying, "songCount" as NSCopying]))
        
    }
    
    /**
    Query for a particular song
    
    :param: songId            the songPerstistenceId
    :param: completionHandler MPMediaItem single instance
    */
    func queryForSongWithId(_ songId:NSNumber, completionHandler:(_ result:MPMediaItem?) -> Void) {
        let mediaItemPersistenceIdPredicate:MPMediaPropertyPredicate =
        MPMediaPropertyPredicate(value: songId, forProperty: MPMediaItemPropertyPersistentID)
        
        let songQuery = MPMediaQuery(filterPredicates: NSSet(object: mediaItemPersistenceIdPredicate) as? Set<MPMediaPredicate>)
        
        completionHandler(songQuery.items?.last)
    }
    
    
    
}
