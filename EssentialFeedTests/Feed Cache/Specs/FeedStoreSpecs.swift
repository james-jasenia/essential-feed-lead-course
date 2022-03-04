//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by james.jasenia on 4/3/22.
//

import Foundation

typealias FailableFeedStoreSpec = FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs & FailableRetrieveFeedStoreSpecs

protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversFoundValuesOnNonEmptyCache()
    func test_retrieve_HasNoSideEffectsOnNonEmptyCache()

    func test_insert_overridesPreviouslyInsertedCacheValues()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    func test_insert_deliversNoErrorOnEmptyCache()

    func test_delete_deliversNoErrorOnEmptyCache()
    
    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_emptiesPreviouslyInsertedCache()

    func test_sideEffects_runSerially()
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieve_hasNoSideEffectsOnRetrievalError()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectsOnDeletionError()
}

