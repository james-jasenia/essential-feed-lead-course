//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by james.jasenia on 13/2/22.
//

import XCTest
import EssentialFeed

class CacheFeedUseCaseTest: XCTestCase {
    
    func test_init_doesNotMessageTheStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receievedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        
        sut.save(anyUnqiueImagesFeed().domain) { _ in }
        
        XCTAssertEqual(store.receievedMessages, [.deletion])
    }
    
    func test_save_doesNotRequestCacheInsertionUponDeletionFailure() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(anyUnqiueImagesFeed().domain) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receievedMessages, [.deletion])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let feed = anyUnqiueImagesFeed()
        
        sut.save(feed.domain) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receievedMessages, [.deletion, .insertion(feed.local, timestamp)])
    }
    
    func test_save_failsUponDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsUponInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWith: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWith: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receievedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(anyUnqiueImagesFeed().domain, completion: { error in
            receievedResults.append(error)
        })
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(receievedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receievedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(anyUnqiueImagesFeed().domain, completion: { error in
            receievedResults.append(error)
        })
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(receievedResults.isEmpty)
    }
    
    //MARK: -- Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedError: NSError?, action: () -> Void) {
        let exp = expectation(description: "Wait for completion")
        
        var capturedError: Error?
        sut.save([anyUnqiueImage()]) { receivedError in
            if let receivedError = receivedError { capturedError = receivedError }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(capturedError as NSError?, expectedError)
    }
    
    private func anyUnqiueImage() -> FeedImage {
        return FeedImage(
            id: UUID(),
            description: "any description",
            location: "any location",
            url: anyURL()
        )
    }
    
    private func anyUnqiueImagesFeed() -> (domain: [FeedImage], local: [LocalFeedImage]) {
        let domain = [anyUnqiueImage(), anyUnqiueImage()]
        let local = domain.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
        return (domain, local)
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com/")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "", code: 0, userInfo: nil)
    }
}
