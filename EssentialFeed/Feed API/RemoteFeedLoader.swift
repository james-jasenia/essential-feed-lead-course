//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by james.jasenia on 17/1/22.
//

import Foundation

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public typealias Result = LoadFeedResult
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (LoadFeedResult) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(data, response):
                completion(RemoteFeedLoader.map(data, with: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, with response: HTTPURLResponse) -> Result {
        do {
            let remoteItems = try FeedItemsMapper.map(data, from: response)
            return Result.success(remoteItems.toDomainItems())
        } catch {
            return Result.failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toDomainItems() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image)}
    }
}
