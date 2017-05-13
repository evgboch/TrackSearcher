//
//  CustomITunesCell.swift
//  TrackSearcher
//
//  Created by Евгений on 15.04.17.
//  Copyright © 2017 Евгений. All rights reserved.
//

import Foundation
import UIKit

class CustomITunesCell: UITableViewCell {

    var upperLabel: UILabel!
    var lowerLabel: UILabel!
    var iconImageView: UIImageView!

    var labelWidth: CGFloat = 0.0

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        upperLabel = UILabel()
        lowerLabel = UILabel()
        iconImageView = UIImageView()

        self.backgroundColor = .lightGray

        upperLabel.font = UIFont.boldSystemFont(ofSize: 17)

        self.addSubview(upperLabel)
        self.addSubview(lowerLabel)
        self.addSubview(iconImageView)

        labelWidth = self.bounds.width - (imageSize + 3*margin)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var upperRect = upperLabel.frame
        var lowerRect = lowerLabel.frame
        var iconImageViewRect = iconImageView.frame

        if let upperLabelHeight = upperLabel.text?.height(withConstrainedWidth: labelWidth,
                                                          font: upperLabel.font),
            let lowerLabelHeight = lowerLabel.text?.height(withConstrainedWidth: labelWidth,
                                                           font: lowerLabel.font) {

            upperRect = CGRect(x: margin, y: 0, width: labelWidth, height: upperLabelHeight)
            lowerRect = CGRect(x: margin, y: max(upperRect.maxY+margin, self.bounds.height/2),
                               width: labelWidth,
                               height: lowerLabelHeight)
        } else {
            upperRect = CGRect(x: margin, y: 0, width: labelWidth, height: 0)
            lowerRect = CGRect(x: margin, y: max(upperRect.maxY+margin, self.bounds.height/2),
                               width: labelWidth,
                               height: 0)
        }
        iconImageViewRect = CGRect(x: self.bounds.width - (imageSize+margin), y: self.bounds.height/2-(imageSize/2),
                                   width: imageSize, height: imageSize)

        upperLabel.frame = upperRect
        lowerLabel.frame = lowerRect
        iconImageView.frame = iconImageViewRect
    }

    func fillTrackCell(atIndexPath: IndexPath, allTracks: [Track]) {
        let upperLabelText = allTracks[atIndexPath.row].artist
        let lowerLabelText = allTracks[atIndexPath.row].title
        let imageURLString = allTracks[atIndexPath.row].artworkURL

        finishFillingCell(upperLabelText: upperLabelText, lowerLabelText: lowerLabelText,
                          imageURLString: imageURLString)
    }

    func fillAlbumCell(atIndexPath: IndexPath, allAlbums: [Album]) {
        let upperLabelText = allAlbums[atIndexPath.row].artistName
        let lowerLabelText = allAlbums[atIndexPath.row].albumName
        let imageURLString = allAlbums[atIndexPath.row].artworkURL

        finishFillingCell(upperLabelText: upperLabelText, lowerLabelText: lowerLabelText,
                          imageURLString: imageURLString)
    }

    func finishFillingCell(upperLabelText: String?, lowerLabelText: String?, imageURLString: String?) {
        self.upperLabel.text = upperLabelText
        self.lowerLabel.text = lowerLabelText

        self.upperLabel.numberOfLines = 0
        self.lowerLabel.numberOfLines = 0
        ImageDownloader.downloadImage(imageURLString: imageURLString) {(downloadedImg) in
            DispatchQueue.main.async {
                self.iconImageView.image = downloadedImg
            }
        }
    }
}
