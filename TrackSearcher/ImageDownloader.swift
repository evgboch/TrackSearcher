//
//  ImageDownloader.swift
//  TrackSearcher
//
//  Created by Евгений on 2.05.17.
//  Copyright © 2017 Евгений. All rights reserved.
//

import UIKit

struct ImageDownloader {

    static var cache = NSCache<NSString, UIImage>()

    static func downloadImage(imageURLString: String?,
                              completionHandler: @escaping (UIImage) -> Void) {
        guard let imgURLString = imageURLString else {
            return
        }
        if let cachedValue = cache.object(forKey: imgURLString as NSString) {
            DispatchQueue.main.async {
                completionHandler(cachedValue)
            }
        }

        guard let imageURL = URL(string: imgURLString) else {
            return
        }
        let task = URLSession.shared.downloadTask(with: imageURL) {(_, _, error) in
            guard error == nil else {
                return
            }

            guard let data = try? Data(contentsOf: imageURL),
                let img = UIImage(data: data) else {
                    return
            }
            cache.setObject(img, forKey: imgURLString as NSString)
            DispatchQueue.main.async {
                completionHandler(img)
            }
        }
        task.resume()
    }
}
