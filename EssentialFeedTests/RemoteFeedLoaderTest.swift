//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by james.jasenia on 16/1/22.
//

import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_HTTPClientInit_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        XCTAssertNil(client.requestedURL)
    }
}
