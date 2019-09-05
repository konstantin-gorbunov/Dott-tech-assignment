//
//  Flickr.swift
//  FlickrViewer
//
//  Created by Kostiantyn Gorbunov on 04/09/2019.
//  Copyright © 2019 Kostiantyn Gorbunov. All rights reserved.
//

import UIKit

let apiKey: String = "3e7cc266ae2b0e0d78e279ce8e361736"

class Flickr {
    
    var session = URLSession.shared
    
    private enum Error: Swift.Error {
        case unknownAPIResponse
        case generic
    }
    
    func searchFlickr(for searchTerm: String, _ page: Int = 1, completion: @escaping (Result<FlickrSearchResults>) -> Void) {
        guard let searchURL = flickrSearchURL(for: searchTerm, page) else {
            completion(Result.error(Error.unknownAPIResponse))
            return
        }
        
        let searchRequest = URLRequest(url: searchURL)
        
        session.dataTask(with: searchRequest) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(Result.error(error))
                }
                return
            }
            
            guard
                let _ = response as? HTTPURLResponse,
                let data = data
                else {
                    DispatchQueue.main.async {
                        completion(Result.error(Error.unknownAPIResponse))
                    }
                    return
            }
            
            do {
                guard
                    let resultsDictionary = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject],
                    let stat = resultsDictionary["stat"] as? String
                    else {
                        DispatchQueue.main.async {
                            completion(Result.error(Error.unknownAPIResponse))
                        }
                        return
                }
                
                switch (stat) {
                case "ok":
                    print("Results processed OK")
                case "fail":
                    DispatchQueue.main.async {
                        completion(Result.error(Error.generic))
                    }
                    return
                default:
                    DispatchQueue.main.async {
                        completion(Result.error(Error.unknownAPIResponse))
                    }
                    return
                }
                
                guard
                    let photosContainer = resultsDictionary["photos"] as? [String: AnyObject],
                    let currentPage = photosContainer["page"] as? Int,
                    let totalPage = photosContainer["pages"] as? Int,
                    let photosReceived = photosContainer["photo"] as? [[String: AnyObject]]
                    else {
                        DispatchQueue.main.async {
                            completion(Result.error(Error.unknownAPIResponse))
                        }
                        return
                }
                
                let flickrPhotos: [FlickrPhoto] = photosReceived.compactMap { photoObject in
                    guard
                        let photoID = photoObject["id"] as? String,
                        let farm = photoObject["farm"] as? Int ,
                        let server = photoObject["server"] as? String ,
                        let secret = photoObject["secret"] as? String
                        else {
                            return nil
                    }
                    
                    let flickrPhoto = FlickrPhoto(photoID: photoID, farm: farm, server: server, secret: secret)
                    
                    self.setFlickrImage(flickrPhoto)
                    flickrPhoto.thumbnail = flickrPhoto.thumbnail ?? UIImage(named: "no_data")
                    return flickrPhoto
                }
                
                let searchResults = FlickrSearchResults(searchTerm: searchTerm, page: currentPage, pages: totalPage, searchResults: flickrPhotos)
                DispatchQueue.main.async {
                    completion(Result.results(searchResults))
                }
            } catch {
                completion(Result.error(error))
                return
            }
            }.resume()
    }
    
    private func setFlickrImage(_ flickrPhoto: FlickrPhoto) {
        guard
            let url = flickrPhoto.flickrImageURL(),
            let imageData = try? Data(contentsOf: url as URL)
            else {
                return
        }
        
        if let image = UIImage(data: imageData) {
            flickrPhoto.thumbnail = image
        }
    }
    
    private func flickrSearchURL(for searchTerm: String, _ page: Int) -> URL? {
        guard let escapedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
            return nil
        }
        
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(escapedTerm)&per_page=48&format=json&nojsoncallback=1&safe_search=1&page=\(page)"
        return URL(string: URLString)
    }
}
