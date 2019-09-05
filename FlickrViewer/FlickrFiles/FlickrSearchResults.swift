//
//  FlickrSearchResults.swift
//  FlickrViewer
//
//  Created by Kostiantyn Gorbunov on 04/09/2019.
//  Copyright © 2019 Kostiantyn Gorbunov. All rights reserved.
//

import Foundation

struct FlickrSearchResults {
    let searchTerm: String
    let page: Int
    let pages: Int
    let searchResults: [FlickrPhoto]
}
