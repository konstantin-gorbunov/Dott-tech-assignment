//
//  FlickrViewerTests.swift
//  FlickrViewerTests
//
//  Created by Kostiantyn Gorbunov on 03/09/2019.
//  Copyright © 2019 Kostiantyn Gorbunov. All rights reserved.
//

import XCTest
@testable import FlickrViewer

class FlickrViewerTests: XCTestCase {

    private let flickr = Flickr()
    
    func testGetPhotosWithExpectedURLHostAndPath() {
        let mockURLSession  = MockURLSession(data: nil, urlResponse: nil, error: nil)
        flickr.session = mockURLSession
        flickr.searchFlickr(for: "any") { result in }
        XCTAssertEqual(mockURLSession.cachedUrl?.host, "api.flickr.com")
        XCTAssertEqual(mockURLSession.cachedUrl?.path, "/services/rest")
    }

    func testGetPhotosSuccessReturnsError() {
        let mockURLSession  = MockURLSession(data: nil, urlResponse: nil, error: nil)
        flickr.session = mockURLSession
        let flickrExpectation = expectation(description: "error result")
        var searchResults: Result<FlickrSearchResults>?

        flickr.searchFlickr(for: "any") { result in
            searchResults = result
            flickrExpectation.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNotNil(searchResults)
            guard let result = searchResults else {
                return
            }
            switch result {
            case .error(_) :
                XCTAssertTrue(true)
            case .results(_):
                XCTAssertTrue(false)
            }
        }
    }
    
    func testGetPhotosSuccessReturnsParsedAndEmpty() {
        let jsonData = "{\"photos\":{\"page\":1,\"pages\":1830,\"perpage\":48,\"total\":\"87806\",\"photo\":[]},\"stat\":\"ok\"}".data(using: .utf8)
        let mockURLSession  = MockURLSession(data: jsonData, urlResponse: HTTPURLResponse(), error: nil)
        flickr.session = mockURLSession
        let flickrExpectation = expectation(description: "error result")
        var searchResults: Result<FlickrSearchResults>?
        
        flickr.searchFlickr(for: "any") { result in
            searchResults = result
            flickrExpectation.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNotNil(searchResults)
            guard let result = searchResults else {
                return
            }
            switch result {
            case .error(_) :
                XCTAssertTrue(false)
            case .results(let results):
                XCTAssertTrue(results.searchResults.count == 0)
            }
        }
    }
    
    func testGetPhotosSuccessReturnsParsedOne() {
        let jsonData = "{\"photos\":{\"page\":1,\"pages\":1830,\"perpage\":48,\"total\":\"87806\",\"photo\":[{\"id\":\"48682762827\",\"owner\":\"80780290@N05\",\"secret\":\"112dfccb7d\",\"server\":\"65535\",\"farm\":66,\"title\":\"ups\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0}]},\"stat\":\"ok\"}".data(using: .utf8)
        let mockURLSession  = MockURLSession(data: jsonData, urlResponse: HTTPURLResponse(), error: nil)
        flickr.session = mockURLSession
        let flickrExpectation = expectation(description: "error result")
        var searchResults: Result<FlickrSearchResults>?
        
        flickr.searchFlickr(for: "any") { result in
            searchResults = result
            flickrExpectation.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNotNil(searchResults)
            guard let result = searchResults else {
                return
            }
            switch result {
            case .error(_) :
                XCTAssertTrue(false)
            case .results(let results):
                XCTAssertTrue(results.searchResults.count == 1)
            }
        }
    }
    
    func testGetPhotosSuccessReturnsParsedTwo() {
        let jsonData = "{\"photos\":{\"page\":1,\"pages\":1830,\"perpage\":48,\"total\":\"87806\",\"photo\":[{\"id\":\"48682762827\",\"owner\":\"80780290@N05\",\"secret\":\"112dfccb7d\",\"server\":\"65535\",\"farm\":66,\"title\":\"ups\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0},{\"id\":\"48682383436\",\"owner\":\"129009394@N08\",\"secret\":\"d79cd62c36\",\"server\":\"65535\",\"farm\":66,\"title\":\"Silence ...\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0}]},\"stat\":\"ok\"}".data(using: .utf8)
        let mockURLSession  = MockURLSession(data: jsonData, urlResponse: HTTPURLResponse(), error: nil)
        flickr.session = mockURLSession
        let flickrExpectation = expectation(description: "error result")
        var searchResults: Result<FlickrSearchResults>?
        
        flickr.searchFlickr(for: "any") { result in
            searchResults = result
            flickrExpectation.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNotNil(searchResults)
            guard let result = searchResults else {
                return
            }
            switch result {
            case .error(_) :
                XCTAssertTrue(false)
            case .results(let results):
                XCTAssertTrue(results.searchResults.count == 2)
            }
        }
    }
}

class MockURLSession: URLSession {
    
    var cachedUrl: URL?
    private let mockTask: MockTask
    
    init(data: Data?, urlResponse: URLResponse?, error: Error?) {
        mockTask = MockTask(data: data, urlResponse: urlResponse, error:
            error)
    }
        
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.cachedUrl = request.url
        mockTask.completionHandler = completionHandler
        return mockTask
    }
}

class MockTask: URLSessionDataTask {
    
    var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
    private let data: Data?
    private let urlResponse: URLResponse?
    private let internalError: Error?

    init(data: Data?, urlResponse: URLResponse?, error: Error?) {
        self.data = data
        self.urlResponse = urlResponse
        internalError = error
    }
    override func resume() {
        DispatchQueue.main.async {
            if let hadler = self.completionHandler {
                hadler(self.data, self.urlResponse, self.internalError)
            }
        }
    }
}
