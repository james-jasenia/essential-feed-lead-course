//
//  FeedViewControllerTests.swift
//  EssentialFeediOS
//
//  Created by james.jasenia on 7/3/22.
//

import XCTest
import UIKit
import EssentialFeed

final class FeedViewController: UIViewController {
    
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.load() { _ in }
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    class LoaderSpy: FeedLoader {
        
        private(set) var loadCallCount: Int = 0
        
        func load(completion: @escaping (LoadFeedResult) -> Void) {
            loadCallCount += 1
        }
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: UIViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
}
