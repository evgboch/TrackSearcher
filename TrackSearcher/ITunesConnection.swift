//
//  ITunesConnection.swift
//  TrackSearcher
//
//  Created by Евгений on 2.05.17.
//  Copyright © 2017 Евгений. All rights reserved.
//

import Foundation
// swiftlint:disable:next prefer_structs_over_classes
class ITunesConnection {

    var albumsSearchResult = [Album]()
    var tracksSearchResult = [Track]()

    private enum SearchType {
        case tracks, albums, tracksFromAlbum
    }

    private init() {}
    static let instance = ITunesConnection()

    private func getItunesURLFor(searchType: SearchType, string: String) -> URL? {
        let defaultURL = URL(string: "")

        guard let formattedString = string.addingPercentEncoding(
            withAllowedCharacters: CharacterSet.urlHostAllowed) else {
                return defaultURL
        }

        switch searchType {
        case .tracks:
            guard let url = URL(string: "https://itunes.apple.com/search?term=\(formattedString)&entity=song") else {
                return defaultURL
            }
            return url
        case .albums:
            guard let url = URL(string: "https://itunes.apple.com/search?term=\(formattedString)&entity=album") else {
                return defaultURL
            }
            return url
        case .tracksFromAlbum:
            guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(string)&entity=song") else {
                return defaultURL
            }
            return url
        }
    }

    func getAlbums(for searchString: String, completionHandler: @escaping ([Album]) -> Void) {

        guard let url = getItunesURLFor(searchType: .albums, string: searchString) else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) {(data, _, error) in

            guard let data = data, error == nil else {
                return
            }

            do {
                guard let itunesDict = try JSONSerialization.jsonObject(
                    with: data, options: .allowFragments) as? [String:Any] else {
                        return
                }

                guard let resultsArray = itunesDict["results"] as? [ [String:Any] ] else {
                    return
                }

                var allAlbums = [Album]()
                for resultsDict in resultsArray {
                    guard let albumIDInt = resultsDict["collectionId"] as? Int,
                        let artistName = resultsDict["artistName"] as? String,
                        let albumName = resultsDict["collectionCensoredName"] as? String,
                        let artworkURL = resultsDict["artworkUrl100"] as? String else {
                            continue
                    }
                    let albumID = String(albumIDInt)
                    if let existingAlbum = CoreDataConnection.albumAlreadyInCD(newAlbumID: albumID) {
                        // Then we don't need to create it again in CD
                        allAlbums.append(existingAlbum)
                        continue
                    }

                    var album: Album!
                    let moc = DataController.instance.managedObjectContext
                    moc.performAndWait {
                        album = Album(context: moc)
                        album.albumID = albumID
                        album.artistName = artistName
                        album.albumName = albumName
                        album.artworkURL = artworkURL
                    }
                    allAlbums.append(album)
                    DispatchQueue.main.async {
                        DataController.instance.saveContext()
                    }
                }
                DispatchQueue.main.async {
                    self.albumsSearchResult = allAlbums
                    completionHandler(allAlbums)
                }
            } catch let error {
                print("Error: \(error)")
            }
        }
        task.resume()
    }

    func getTracks(for searchString: String, inAlbum: Bool, completionHandeler: @escaping ([Track]) -> Void) {
        var url: URL!
        if (inAlbum) == (true) {
            guard let tempUrl = getItunesURLFor(searchType: .tracksFromAlbum, string: searchString) else {
                return
            }
            url = tempUrl
        } else {
            guard let tempUrl = getItunesURLFor(searchType: .tracks, string: searchString) else {
                return
            }
            url = tempUrl
        }
        let task = URLSession.shared.dataTask(with: url) {(data, _, error) in
            guard let data = data, error == nil else {
                return
            }
            do {
                guard let itunesDict = try JSONSerialization.jsonObject(
                    with: data, options: .allowFragments) as? [String:Any] else {
                        return
                }
                guard let resultsArray = itunesDict["results"] as? [ [String:Any] ] else {
                    return
                }
                var allTracks = [Track]()
                for resultsDict in resultsArray {
                    guard let artist = resultsDict["artistName"] as? String,
                        let trackTitle = resultsDict["trackName"] as? String,
                        let artworkURL = resultsDict["artworkUrl100"] as? String,
                        let trackIdInt = resultsDict["trackId"] as? Int else {
                            continue
                    }
                    let trackId = String(trackIdInt)
                    if let existingTrack = CoreDataConnection.trackAlreadyInCD(newTrackID: trackId) {
                        // Then we don't need to create it again in CD
                        allTracks.append(existingTrack)
                        continue
                    }
                    var track: Track!
                    let moc = DataController.instance.managedObjectContext
                    moc.performAndWait {
                        track = Track(context: moc)
                        track.artist = artist
                        track.title = trackTitle
                        track.artworkURL = artworkURL
                        track.trackId = trackId
                    }
                    allTracks.append(track)
                    DispatchQueue.main.async {
                        DataController.instance.saveContext()
                    }
                }
                DispatchQueue.main.async {
                    self.tracksSearchResult = allTracks
                    completionHandeler(allTracks)
                }
            } catch let error {
                print("Error: \(error)")
            }
        }
        task.resume()
    }
}
