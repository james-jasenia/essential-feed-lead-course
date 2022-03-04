//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by james.jasenia on 13/2/22.
//

import Foundation

public enum RetrieveCacheFeedResult {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}


public protocol FeedStore {
    typealias RetrievalCompletion = (RetrieveCacheFeedResult) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias DeletionCompletion = (Error?) -> Void
    
    ///The completion handler can be invoked in any thread.
    ///Clients are responsible for dispatching to the approparite threads.
    func retrieve(completion: @escaping RetrievalCompletion)
    
    ///The completion handler can be invoked in any thread.
    ///Clients are responsible for dispatching to the approparite threads.
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    ///The completion handler can be invoked in any thread.
    ///Clients are responsible for dispatching to the approparite threads.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
}



