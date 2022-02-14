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
    var receievedMessages = [ReceievedMessage]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receievedMessages.append(.deletion)
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletion.append(completion)
        receievedMessages.append(.insertion(feed, timestamp))
    }
    
    enum ReceievedMessage: Equatable {
        case deletion
        case insertion([LocalFeedImage], Date)
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
