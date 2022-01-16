//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by james.jasenia on 16/1/22.
//

import XCTest

class RemoteFeedLoader {
    
    let client: HTTPClient
    let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL = url
    }
}


class RemoteFeedLoaderTests: XCTestCase {
    
    func test_HTTPClientInit_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "http://www.any-url.com/")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
}
