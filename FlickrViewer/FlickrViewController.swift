//
//  FlickrViewController.swift
//  FlickrViewer
//
//  Created by Kostiantyn Gorbunov on 03/09/2019.
//  Copyright © 2019 Kostiantyn Gorbunov. All rights reserved.
//

import UIKit

final class FlickrViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private enum Constants {
        static let reuseIdentifier = "FlickrCell"
        static let itemsPerRow: CGFloat = 3
        static let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        static let searchResultPageThumbnailsInMemory: Int = 5
    }
    
    private var searches: [FlickrSearchResults] = []
    private let flickr = Flickr()
    private let activityIndicator = UIActivityIndicatorView(style: .gray)
    private var loadingInProgress = false {
        didSet {
            if loadingInProgress {
                searchBar.addSubview(activityIndicator)
                activityIndicator.frame = searchBar.bounds
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }
    }
    
    // MARK: - private
    private func photo(for indexPath: IndexPath) -> FlickrPhoto {
        return searches[indexPath.section].searchResults[indexPath.row]
    }
    
    private func refreshWithData(_ results: FlickrSearchResults? = nil) {
        if results?.page == 1 || results == nil {
            searches.removeAll()
        }
        if let resultList = results {
            searches.append(resultList)
            cleanThumbnails()
        }
        collectionView?.reloadData()
    }
    
    private func requestPhotos(_ text: String, _ page: Int = 1) {
        loadingInProgress = true
        
        flickr.searchFlickr(for: text, page) { searchResults in
            switch searchResults {
            case .error(let error) :
                print("Error Searching: \(error)")
            case .results(let results):
                print("Found \(results.searchResults.count) matching \(results.searchTerm) on page \(results.page)")
                self.refreshWithData(results)
            }
            self.loadingInProgress = false
        }
    }
    
    private func requestNextPageFetch() {
        if loadingInProgress {
            return
        }
        guard let lastResult = searches.last else {
            return
        }
        if lastResult.pages == lastResult.page {
            print("No more images matching \(lastResult.searchTerm)")
            return
        }
        requestPhotos(lastResult.searchTerm, lastResult.page + 1)
    }
    
    private func cleanThumbnails() {
        let maxCleanChankIndex = searches.count - Constants.searchResultPageThumbnailsInMemory
        if maxCleanChankIndex <= 0 {
            return
        }
        for index in 0..<maxCleanChankIndex {
            for result in searches[index].searchResults {
                result.thumbnail = nil
            }
            print("search result from page \(index + 1) does not have more templates image data in memory. Memory manager is happy!")
        }
    }
}

extension FlickrViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            refreshWithData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let text = searchBar.text, text.isEmpty == false else {
            refreshWithData()
            return
        }
        requestPhotos(text)
    }
}

extension FlickrViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searches[section].searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.reuseIdentifier,
                                                      for: indexPath) as! FlickrPhotoCell
        let flickrPhoto = photo(for: indexPath)
        if let thumbnail = flickrPhoto.thumbnail {
            cell.imageView.image = thumbnail
        } else if let imageLocalURL = flickrPhoto.thumbnailLocalURL,
                let imageData = try? Data(contentsOf: imageLocalURL as URL) {
            cell.imageView.image = UIImage(data: imageData)
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return searches.count
    }
}

extension FlickrViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = Constants.sectionInsets.left * (Constants.itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / Constants.itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return Constants.sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.sectionInsets.left
    }
}

extension FlickrViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - 4 * scrollView.frame.size.height {
            requestNextPageFetch()
        }
    }
}
