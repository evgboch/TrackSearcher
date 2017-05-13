//
//  Track+CoreDataProperties.swift
//  TrackSearcher
//
//  Created by Евгений on 2.05.17.
//  Copyright © 2017 Евгений. All rights reserved.
//

import Foundation
import CoreData

extension Track {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Track> {
        return NSFetchRequest<Track>(entityName: "Track")
    }

    @NSManaged public var artist: String?
    @NSManaged public var artworkURL: String?
    @NSManaged public var title: String?
    @NSManaged public var trackId: String?
    @NSManaged public var album: Album?

}
