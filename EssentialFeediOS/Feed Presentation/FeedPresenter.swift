//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by James Jasenia on 30/3/22.
//

import Foundation
import EssentialFeed

protocol FeedLoadingView {
    func display(isLoading: Bool)
}
protocol FeedView {
    func display(feed: [FeedImage])
}

final class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var feedView: FeedView?
    var loadingView: FeedLoadingView?

    func loadFeed() {
        loadingView?.display(isLoading: true)
        feedLoader.load { [weak self] result in
            
            if case let .success(feed) = result {
                self?.feedView?.display(feed: feed)
            }
            
            self?.loadingView?.display(isLoading: false)
        }
    }
}
