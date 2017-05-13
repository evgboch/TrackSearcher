//
//  ITunesSearchViewController.swift
//  TrackSearcher
//
//  Created by Евгений on 2.05.17.
//  Copyright © 2017 Евгений. All rights reserved.
//

import Foundation
import UIKit
import CoreData

var imageSize: CGFloat = 100
var margin: CGFloat = 8
// Шрифты будут необходимы для определения высоты ячеек
let nameLabelFont: UIFont = CustomITunesCell().upperLabel.font
let titleLabelFont: UIFont = CustomITunesCell().lowerLabel.font

class ITunesSearchViewController: UITableViewController {

    var itunesConnection = ITunesConnection.instance

    var searchString = ""
    let searchController = UISearchController(searchResultsController: nil)

    var tracksResults = [Track]()
    var albumsResults = [Album]()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .lightGray

        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false

        searchController.searchBar.scopeButtonTitles = ["Song title", "Album"]
        tableView.tableHeaderView = searchController.searchBar
    }

    override func viewDidAppear(_ animated: Bool) {
        searchController.isActive = true
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections = 0

        if (searchString == "") || (noAppropriateTracks())
            || (noAppropriateAlbums()) {
            displayMessageForNoResults(in: tableView, for: searchString)
        } else {
            tableView.separatorStyle = .singleLine
            numOfSections = 1
            tableView.backgroundView = nil
        }
        return numOfSections
    }

    func noAppropriateTracks() -> Bool {
        return (isSearchingBySongTitle()) && (tracksResults.isEmpty)
    }

    func noAppropriateAlbums() -> Bool {
        return (isSearchingByAlbumName()) && (albumsResults.isEmpty)
    }

    func displayMessageForNoResults(in tableView: UITableView, for request: String) {
        let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0,
                                                width: tableView.bounds.size.width,
                                                height: tableView.bounds.size.height))
        if (request) == ("") {
            if isSearchingBySongTitle() {
                noDataLabel.text = "Enter the title of the song"
            } else {
                noDataLabel.text = "Enter the title of the album"
            }
        } else {
            noDataLabel.text = "No results for request '\(searchString)'"
        }
        noDataLabel.textColor = .black
        noDataLabel.textAlignment = .center
        tableView.backgroundView = noDataLabel
        tableView.separatorStyle = .none
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchingBySongTitle() {
            return tracksResults.count
        } else {
            return albumsResults.count
        }
    }

    func isSearchingBySongTitle() -> Bool {
        return searchController.searchBar.selectedScopeButtonIndex == 0
    }

    func isSearchingByAlbumName() -> Bool {
        return searchController.searchBar.selectedScopeButtonIndex == 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (isSearchingBySongTitle()) == (true) {
            return configureCell(tableVIew: tableView, indexPath: indexPath, searchingBySongTitle: true,
                                 tracksResults: tracksResults, albumsResults: albumsResults)
        } else {
            return configureCell(tableVIew: tableView, indexPath: indexPath, searchingBySongTitle: false,
                                 tracksResults: tracksResults, albumsResults: albumsResults)
        }

    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (isSearchingBySongTitle()) == (true) {
            return findHeightOfCell(tableView: tableView, indexPath: indexPath, searchingBySongTitle: true,
                                    tracksResults: tracksResults, albumsResults: albumsResults)
        } else {
            return findHeightOfCell(tableView: tableView, indexPath: indexPath, searchingBySongTitle: false,
                                    tracksResults: tracksResults, albumsResults: albumsResults)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (isSearchingByAlbumName()) == (false) {
            return
        }
        let currAlbum = albumsResults[indexPath.row]
        guard let albumID = currAlbum.albumID else {
            return
        }
        itunesConnection.getTracks(for: albumID, inAlbum: true, completionHandeler: {(allTracks) in
            DispatchQueue.main.async {
                self.tracksResults = allTracks
                let tracksFromAlbumVC = TracksFromAlbumViewController()
                tracksFromAlbumVC.title = currAlbum.albumName
                self.searchController.isActive = false
                self.navigationController?.pushViewController(tracksFromAlbumVC, animated: true)
            }
        })
    }
}

extension ITunesSearchViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchInCoreData(searchBar: searchBar)
    }

    func searchInCoreData(searchBar: UISearchBar) {
        guard let searchStr = searchBar.text else {
            return
        }
        searchString = searchStr

        if isSearchingBySongTitle() {
            guard let tracks = CoreDataConnection.fetchTracks(searchString: searchBar.text) else {
                return
            }
            DispatchQueue.main.async {
                self.tracksResults = tracks
                self.tableView.reloadData()
            }
        } else {
            guard let albums = CoreDataConnection.fetchAlbums(searchString: searchBar.text) else {
                return
            }
            DispatchQueue.main.async {
                self.albumsResults = albums
                self.tableView.reloadData()
            }
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchString = ""
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchInCoreData(searchBar: searchBar)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchStr = searchController.searchBar.text else {
            return
        }
        searchString = searchStr

        if isSearchingBySongTitle() {
            updateTracksSearchResult(for: searchString)
        } else {
            updateAlbumsSearchResult(for: searchString)
        }
    }

    func updateTracksSearchResult(for searchString: String) {
        itunesConnection.getTracks(for: searchString, inAlbum: false) { (tracks: [Track]) in
            DispatchQueue.main.async {
                self.tracksResults = tracks
                self.tableView.reloadData()
            }
        }
    }

    func updateAlbumsSearchResult(for searchString: String) {
        itunesConnection.getAlbums(for: searchString) { (albums: [Album]) in
            DispatchQueue.main.async {
                self.albumsResults = albums
                self.tableView.reloadData()
            }
        }
    }
}
