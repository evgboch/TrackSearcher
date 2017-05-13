//
//  CoreDataConnection.swift
//  TrackSearcher
//
//  Created by Евгений on 2.05.17.
//  Copyright © 2017 Евгений. All rights reserved.
//

import Foundation
import CoreData
// swiftlint:disable:next prefer_structs_over_classes
class CoreDataConnection {

    static func fetchTracks(searchString: String?) -> [Track]? {
        guard let searchString = searchString else {
            return nil
        }
        let moc = DataController.instance.managedObjectContext
        let tracksFetchRequest: NSFetchRequest<Track> = Track.fetchRequest()
        tracksFetchRequest.predicate = NSPredicate(format: "(title contains[cd] %@) OR (artist contains[cd] %@)",
                                                   searchString, searchString)
        do {
            let results = try moc.fetch(tracksFetchRequest)
            return results
        } catch {
            print("Coudn't fetch")
            return nil
        }
    }

    static func fetchAlbums(searchString: String?) -> [Album]? {
        guard let searchString = searchString else {
            return nil
        }
        let moc = DataController.instance.managedObjectContext
        let albumsFetchRequest: NSFetchRequest<Album> = Album.fetchRequest()
        albumsFetchRequest.predicate = NSPredicate(
            format: "(albumName contains[cd] %@) OR (artistName contains[cd] %@)",
            searchString, searchString)
        do {
            let results = try moc.fetch(albumsFetchRequest)
            return results
        } catch {
            print("Coudn't fetch")
            return nil
        }
    }

    static func trackAlreadyInCD(newTrackID: String) -> Track? {
        let moc = DataController.instance.managedObjectContext
        let trackFetchRequest: NSFetchRequest<Track> = Track.fetchRequest()
        trackFetchRequest.predicate = NSPredicate(format: "trackId == %@", newTrackID)
        do {
            let result = try moc.fetch(trackFetchRequest)
            assert(result.count <= 1, "There are duplicates in CoreData!")
            if result.count == 1 {
                return result.first
            } else {
                return nil
            }
        } catch {
            print("Couldn't fetch a single track")
            return nil
        }
    }

    static func albumAlreadyInCD(newAlbumID: String) -> Album? {
        let moc = DataController.instance.managedObjectContext
        let albumFetchRequest: NSFetchRequest<Album> = Album.fetchRequest()
        albumFetchRequest.predicate = NSPredicate(format: "albumID == %@", newAlbumID)
        do {
            let result = try moc.fetch(albumFetchRequest)
            assert(result.count <= 1, "There are duplicates in CoreData!")
            if result.count == 1 {
                return result.first
            } else {
                return nil
            }
        } catch {
            print("Couldn't fetch a single album")
            return nil
        }
    }
}
