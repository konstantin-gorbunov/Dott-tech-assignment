# Flickr viewer
The single view application for display results of user search request in UICollectionView with 3 columns.

Based on standard MVC architecture.

Solved problem:
- endless scrolling based on pagination (48 results in one chank).
- caching based on saving the downloaded file in Documents user folder;
- 5 last search result pages keep image data in memory (faster than using a cache);

Unit test:
- related only to Flickr download and parsing mechanism.

Problem:
- the first search result presenting is too long (if it is not cached)

Possible solution:
- show empty frames and download each image asynchronously

![](demo.gif)
