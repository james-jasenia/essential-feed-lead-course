//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by james.jasenia on 16/1/22.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
