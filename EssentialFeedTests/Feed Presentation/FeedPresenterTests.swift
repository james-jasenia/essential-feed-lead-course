//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by james.jasenia on 11/4/2022.
//

import XCTest

final class FeedPresenter {
    let errorView: FeedErrorView
    
    init(errorView: FeedErrorView) {
        self.errorView = errorView
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
    }
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
}

class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessageToView() {
        let view = makeSUT().view
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages.")
    }
    
    func test_didStartLoadFeeding_displaysNoErrorMessage() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [.display(errorMessage: nil)])
    }
    
    private func makeSUT() -> (presenter: FeedPresenter, view: FeedViewSpy) {
        let view = FeedViewSpy()
        let presenter = FeedPresenter(errorView: view)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(presenter)
        return (presenter, view)
    }
    
    private class FeedViewSpy: FeedErrorView {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case display(errorMessage: String?)
        }
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
    }
}


