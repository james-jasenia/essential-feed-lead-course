//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by james.jasenia on 13/2/22.
//

import XCTest
import EssentialFeed

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    
    private var deletionCompletions = [DeletionCompletion]()
    var receievedMessages = [ReceievedMessage]()
    
    enum ReceievedMessage: Equatable {
        case deletion
        case insertion([FeedItem], Date)
    }
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receievedMessages.append(.deletion)
    }
    
    func insert(_ items: [FeedItem], timestamp: Date) {
        receievedMessages.append(.insertion(items, timestamp))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
}

class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate())
            } else {
                completion(error)
            }
        }
    }
}

class CacheFeedUseCaseTest: XCTestCase {
    
    func test_init_doesNotMessageTheStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receievedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [unqiueFeedItem(), unqiueFeedItem()]
        
        sut.save(items) { _ in }
        
        XCTAssertEqual(store.receievedMessages, [.deletion])
    }
    
    func test_save_doesNotRequestCacheInsertionUponDeletionFailure() {
        let (sut, store) = makeSUT()
        let items = [unqiueFeedItem(), unqiueFeedItem()]
        let deletionError = anyNSError()
        
        sut.save(items) { _ in }
        store.complete(with: deletionError)
        
        XCTAssertEqual(store.receievedMessages, [.deletion])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let items = [unqiueFeedItem(), unqiueFeedItem()]
        
        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receievedMessages, [.deletion, .insertion(items, timestamp)])
    }
    
    func test_save_returnsDeletionErrorUponDeletionError() {
        let (sut, store) = makeSUT()
        let items = [unqiueFeedItem(), unqiueFeedItem()]
        let deletionError = anyNSError()
        let exp = expectation(description: "Wait for completion")
        
        var capturedError: Error?
        sut.save(items) { receivedError in
            if let receivedError = receivedError { capturedError = receivedError }
            exp.fulfill()
        }
        store.complete(with: deletionError)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(store.receievedMessages, [.deletion])
        XCTAssertEqual(capturedError as NSError?, deletionError)
    }
    
    //MARK: -- Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func unqiueFeedItem() -> FeedItem {
        return FeedItem(
            id: UUID(),
            description: "any description",
            location: "any location",
            imageURL: anyURL()
        )
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com/")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "", code: 0, userInfo: nil)
    }
}
