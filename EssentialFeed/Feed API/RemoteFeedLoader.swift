//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by james.jasenia on 17/1/22.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            
            case let .success(data, response):
                if response.statusCode == 200 {
                    do {
                        let items = try FeedItemsMapper.map(data, response)
                        completion(.success(items))
                    } catch {
                        completion(.failure(.invalidData))
                    }
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private class FeedItemsMapper {
    
    internal struct Root: Decodable {
        let items: [Item]
    }

    internal struct Item: Decodable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let image: URL
        
        var feedItems: FeedItem {
            return FeedItem(id: id,
                            description: description,
                            location: location,
                            imageURL: image
            )
        }
    }
    
    static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData }
        
        return try JSONDecoder().decode(Root.self, from: data).items.map { $0.feedItems }
    }
}
