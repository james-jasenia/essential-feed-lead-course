//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by james.jasenia on 18/2/22.
//

import XCTest
import EssentialFeed

class ValidateFeedCacheUseCaseTest: XCTestCase {
    
    func test_init_doesNotMessageTheStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receievedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receievedMessages, [.retrieval, .deletion])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receievedMessages, [.retrieval])
    }
    
    func test_validateCache_doesNotDeleteLessThanSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let anyFeed = anyUnqiueImagesFeed()
        
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: anyFeed.local, timestamp: lessThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receievedMessages, [.retrieval])
    }
    
    func test_validateCache_deletesCacheOnExactlySevenDaysOld() {
        let fixedCurrentDate = Date()
        let exactlySevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        let anyFeed = anyUnqiueImagesFeed()
        
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: anyFeed.local, timestamp: exactlySevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receievedMessages, [.retrieval, .deletion])
    }
    
    func test_validateCache_deletesCacheOnOlderThanSevenDaysOld() {
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let anyFeed = anyUnqiueImagesFeed()
        
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: anyFeed.local, timestamp: moreThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receievedMessages, [.retrieval, .deletion])
    }
    
    func test_validateCache_doesNotDeliverInvalidCacheWhenSUTIsDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

        sut?.validateCache()
        
        sut = nil
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receievedMessages, [.retrieval])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }

}




