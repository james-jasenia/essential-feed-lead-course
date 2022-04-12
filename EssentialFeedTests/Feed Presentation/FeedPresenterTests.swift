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
        let view = FeedViewSpy()
        
        _ = FeedPresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages.")
    }
    
    private class FeedViewSpy {
        let messages = [Any]()
    }
}


