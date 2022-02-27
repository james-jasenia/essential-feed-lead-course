//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by james.jasenia on 13/2/22.
//

import Foundation

//MARK: -- LocalFeedLoader
public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

//MARK: -- Save Use Case
extension LocalFeedLoader {
    public typealias SaveResult = Error?
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] deletionError in
            guard let self = self else { return }
            
            if let deletionError = deletionError {
                completion(deletionError)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocalFeedImage(), timestamp: currentDate()) { [weak self] insertionError in
            guard self != nil else { return }
            if let insertionError = insertionError {
                completion(insertionError)
            } else {
                completion(nil)
            }
        }
    }
}

//MARK: -- Load Use Case
extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = LoadFeedResult
    
    public func load(completion: @escaping (LoadFeedResult) -> Void) {
        store.retrieve() { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .found(feed, timestamp) where FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                completion(.success(feed.toDomainFeedImage()))
            case .empty, .found:
                completion(.success([]))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
//MARK: -- Validate Use Case
extension LocalFeedLoader {
    
    public func validateCache() {
        store.retrieve() { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed() { _ in }
                
            case let .found(_, timestamp) where !FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed() { _ in }
                
            case .empty, .found: break
            }
        }
    }
}

//MARK: -- Mappers
private extension Array where Element == FeedImage {
    func toLocalFeedImage() -> [LocalFeedImage] {
        return map { LocalFeedImage(
            id: $0.id,
            description: $0.description,
            location: $0.location,
            url: $0.url
        )}
    }
}

private extension Array where Element == LocalFeedImage {
    func toDomainFeedImage() -> [FeedImage] {
        return map { FeedImage(
            id: $0.id,
            description: $0.description,
            location: $0.location,
            url: $0.url
        )}
    }
}

