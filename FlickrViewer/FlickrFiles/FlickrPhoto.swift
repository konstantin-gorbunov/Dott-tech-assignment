//
//  FlickrPhoto.swift
//  FlickrViewer
//
//  Created by Kostiantyn Gorbunov on 04/09/2019.
//  Copyright © 2019 Kostiantyn Gorbunov. All rights reserved.
//

import UIKit

class FlickrPhoto {
    
    var thumbnail: UIImage?
    
    private let photoID: String
    private let farm: Int
    private let server: String
    private let secret: String
    
    init (photoID: String, farm: Int, server: String, secret: String) {
        self.photoID = photoID
        self.farm = farm
        self.server = server
        self.secret = secret
    }
    
    func flickrImageURL(_ size: String = "t") -> URL? {
        if let url =  URL(string: "https://farm\(farm).static.flickr.com/\(server)/\(photoID)_\(secret)_\(size).jpg") {
            return url
        }
        return nil
    }    
}
