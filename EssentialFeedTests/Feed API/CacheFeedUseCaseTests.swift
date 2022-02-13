//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by james.jasenia on 13/2/22.
//

import XCTest

class FeedCacheStore {
    var deleteCachedFeedCallCount = 0
}

class LocalFeedLoader {
    let store: FeedCacheStore
    
    init(store: FeedCacheStore) {
        self.store = store
    }
}

class CacheFeedUseCaseTest: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedCacheStore()
        _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
}
