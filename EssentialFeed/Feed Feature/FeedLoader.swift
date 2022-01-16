//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by james.jasenia on 16/1/22.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
