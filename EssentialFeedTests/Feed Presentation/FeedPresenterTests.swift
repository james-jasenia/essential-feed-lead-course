//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by james.jasenia on 11/4/2022.
//

import XCTest
@testable import EssentialFeediOS

class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessageToView() {
        let sut = makeSUT()
        
    }
    
    private func makeSUT() -> FeedPresenter {
        let view = FeedViewSpy()
        let presenter = FeedPresenter(
            feedView: view,
            loadingView: view,
            errorView: view
        )
    }
    
    private struct FeedViewSpy: FeedView, FeedLoadingView, FeedErrorView {
        
        var messages: [Messages] = []
        
        init() {}
        
        enum Messages {
            
        }
    }
}


