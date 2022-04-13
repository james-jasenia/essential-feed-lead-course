//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by james.jasenia on 11/4/2022.
//

import XCTest
import EssentialFeed

class FeedPresenterTests: XCTestCase {
    
    func test_title_isLocalised() {
        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
    }
    
    func test_init_doesNotSendMessageToView() {
        let view = makeSUT().view
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages.")
    }
    
    func test_didStartLoadFeeding_displaysNoErrorMessage_displaysIsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [.display(errorMessage: .none), .display(isLoading: true)])
    }
    
    func test_didFinishLoadingFeed_displaysFeedAndStopsLoading() {
        let (sut, view) = makeSUT()
        let feed = anyUnqiueImageFeed().domain
        
        sut.didFinishLoadingFeed(with: feed)
        
        XCTAssertEqual(view.messages, [.display(feed: feed), .display(isLoading: false)])
    }
    
    func test_didFinishLoadingWithError_displaysErrorAndStopsLoading() {
        let (sut, view) = makeSUT()
        let error = anyNSError()
        
        sut.didFinishLoading(with: error)
        
        XCTAssertEqual(view.messages, [.display(isLoading: false), .display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR"))])
    }
    
    private func makeSUT() -> (presenter: FeedPresenter, view: FeedViewSpy) {
        let view = FeedViewSpy()
        let presenter = FeedPresenter(errorView: view, loadingView: view, feedView: view)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(presenter)
        return (presenter, view)
    }
    
    private class FeedViewSpy: FeedErrorView, FeedLoadingView, FeedView {
        
        private(set) var messages = Set<Message>()
        
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(feed: [FeedImage])
        }
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedViewModel) {
            messages.insert(.display(feed: viewModel.feed))
        }
    }
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}


