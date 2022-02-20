//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by james.jasenia on 19/2/22.
//

import Foundation
import EssentialFeed

func anyUnqiueImagesFeed() -> (domain: [FeedImage], local: [LocalFeedImage]) {
    let domain = [anyUnqiueImage(), anyUnqiueImage()]
    let local = domain.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    return (domain, local)
}

func anyUnqiueImage() -> FeedImage {
    return FeedImage(
        id: UUID(),
        description: "any description",
        location: "any location",
        url: anyURL()
    )
}

extension Date {
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -7)
    }
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
