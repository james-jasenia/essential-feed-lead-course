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
                    let decoder = JSONDecoder()
                    do {
                        _ = try decoder.decode(FeedItem.self, from: data)
                        completion(.success([]))
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


