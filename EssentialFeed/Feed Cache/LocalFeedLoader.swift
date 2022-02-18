//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by james.jasenia on 13/2/22.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
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
    
    public func load(completion: @escaping (LoadFeedResult) -> Void) {
        store.retrieve() { [unowned self] result in
            switch result {
            case let .found(feed, timestamp) where self.validate(timestamp):
                completion(.success(feed.toDomainFeedImage()))
            case .found:
                self.store.deleteCachedFeed() { _ in }
                completion(.success([]))
            case .empty:
                completion(.success([]))
            case let .failure(error):
                self.store.deleteCachedFeed() { _ in }
                completion(.failure(error))
            }
        }
    }
    
    private var maxCacheAgeInDays: Int { return 7 }
    
    private func validate(_ timestamp: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
        return currentDate() < maxCacheAge
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

