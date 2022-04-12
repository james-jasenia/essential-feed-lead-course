//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by james.jasenia on 11/4/2022.
//

import XCTest

final class FeedPresenter {
    init(view: Any) {}
}

class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessageToView() {
        let view = makeSUT().view
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages.")
    }
    
    private func makeSUT() -> (presenter: FeedPresenter, view: FeedViewSpy) {
        let view = FeedViewSpy()
        let presenter = FeedPresenter(view: view)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(presenter)
        return (presenter, view)
    }
    
    private class FeedViewSpy {
        let messages = [Any]()
    }
}


