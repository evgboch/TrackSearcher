//
//  TracksFromAlbumViewController.swift
//  TrackSearcher
//
//  Created by Евгений on 15.04.17.
//  Copyright © 2017 Евгений. All rights reserved.
//

import UIKit
import CoreData

class TracksFromAlbumViewController: UITableViewController {

    var tracksResults: [Track] = []
    var albumsResults: [Album] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .lightGray

        tracksResults = ITunesConnection.instance.tracksSearchResult
        albumsResults = ITunesConnection.instance.albumsSearchResult
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracksResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCell(tableVIew: tableView, indexPath: indexPath, searchingBySongTitle: true,
                             tracksResults: tracksResults, albumsResults: albumsResults)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return findHeightOfCell(tableView: tableView, indexPath: indexPath, searchingBySongTitle: true,
                                tracksResults: tracksResults, albumsResults: albumsResults)
    }
}

extension UITableViewController {

    func configureCell(tableVIew: UITableView, indexPath: IndexPath, searchingBySongTitle: Bool,
                       tracksResults: [Track], albumsResults: [Album]) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ITunesCell") as? CustomITunesCell else {
            let cell = CustomITunesCell(style: .default, reuseIdentifier: "ITunesCell")
            fillCell(cell: cell, atIndexPath: indexPath, searchingBySongTitle: searchingBySongTitle,
                     tracksResults: tracksResults, albumsResults: albumsResults)
            return cell
        }
        fillCell(cell: cell, atIndexPath: indexPath, searchingBySongTitle: searchingBySongTitle,
                 tracksResults: tracksResults, albumsResults: albumsResults)
        return cell
    }

    func fillCell(cell: CustomITunesCell, atIndexPath: IndexPath, searchingBySongTitle: Bool,
                  tracksResults: [Track], albumsResults: [Album]) {
        if (searchingBySongTitle) == (true) {
            cell.fillTrackCell(atIndexPath: atIndexPath, allTracks: tracksResults)
        } else {
            cell.fillAlbumCell(atIndexPath: atIndexPath, allAlbums: albumsResults)
        }
    }

    func findHeightOfCell(tableView: UITableView, indexPath: IndexPath, searchingBySongTitle: Bool,
                          tracksResults: [Track], albumsResults: [Album]) -> CGFloat {

        let upperText: String
        let lowerText: String

        if (searchingBySongTitle) == (true) {
            guard let text1 = tracksResults[indexPath.row].artist,
                let text2 = tracksResults[indexPath.row].title else {
                    return imageSize + 2*margin
            }
            upperText = text1
            lowerText = text2
        } else {
            guard let text1 = albumsResults[indexPath.row].artistName,
                let text2 = albumsResults[indexPath.row].albumName else {
                    return imageSize + 2*margin
            }
            upperText = text1
            lowerText = text2
        }

        let viewWidth = self.view.bounds.width
        let labelWidth = viewWidth - imageSize - 3*margin
        return max(upperText.height(withConstrainedWidth: labelWidth, font: nameLabelFont) +
            lowerText.height(withConstrainedWidth: labelWidth, font: titleLabelFont) +
            7*margin, imageSize + 2*margin)
    }
}

extension String {

    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSFontAttributeName: font],
                                            context: nil)
        return boundingBox.height
    }
}
