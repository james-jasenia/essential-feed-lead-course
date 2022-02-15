//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by james.jasenia on 14/2/22.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    
    private var insertionCompletion = [InsertionCompletion]()
    private var deletionCompletions = [DeletionCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()
    var receievedMessages = [ReceievedMessage]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receievedMessages.append(.deletion)
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        receievedMessages.append(.retrieval)
        retrievalCompletions.append(completion)
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletion.append(completion)
        receievedMessages.append(.insertion(feed, timestamp))
    }
    
    enum ReceievedMessage: Equatable {
        case deletion
        case insertion([LocalFeedImage], Date)
        case retrieval
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletion[index](error)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](error)
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
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompletions[index](nil)
    }
}
