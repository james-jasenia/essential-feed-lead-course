//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by james.jasenia on 13/2/22.
//

import XCTest
import EssentialFeed

protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
}

class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [unowned self] deletionError in
            if deletionError == nil {
                self.store.insert(items, timestamp: self.currentDate()) { insertionError in
                    if let insertionError = insertionError {
                        completion(insertionError)
                    } else {
                        completion(nil)
                    }
                }
            } else {
                completion(deletionError)
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
        let items = [anyUnqiueItem(), anyUnqiueItem()]
        
        sut.save(items) { _ in }
        
        XCTAssertEqual(store.receievedMessages, [.deletion])
    }
    
    func test_save_doesNotRequestCacheInsertionUponDeletionFailure() {
        let (sut, store) = makeSUT()
        let items = [anyUnqiueItem(), anyUnqiueItem()]
        let deletionError = anyNSError()
        
        sut.save(items) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receievedMessages, [.deletion])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let items = [anyUnqiueItem(), anyUnqiueItem()]
        
        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receievedMessages, [.deletion, .insertion(items, timestamp)])
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
        sut.save([anyUnqiueItem()]) { receivedError in
            if let receivedError = receivedError { capturedError = receivedError }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(capturedError as NSError?, expectedError)
    }
    
    private func anyUnqiueItem() -> FeedItem {
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
    
    class FeedStoreSpy: FeedStore {
        
        private var insertionCompletion = [InsertionCompletion]()
        private var deletionCompletions = [DeletionCompletion]()
        var receievedMessages = [ReceievedMessage]()
        
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            deletionCompletions.append(completion)
            receievedMessages.append(.deletion)
        }
        
        func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
            insertionCompletion.append(completion)
            receievedMessages.append(.insertion(items, timestamp))
        }
        
        enum ReceievedMessage: Equatable {
            case deletion
            case insertion([FeedItem], Date)
        }
        
        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletion[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            deletionCompletions[index](nil)
        }
        
        func completeInsertionSuccessfully(at index: Int = 0) {
            insertionCompletion[index](nil)
        }
        
        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletions[index](error)
        }
    }
}
