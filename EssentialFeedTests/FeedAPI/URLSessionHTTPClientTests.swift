//
//  URLSessionHTTPClient.swift
//  EssentialFeedTests
//
//  Created by james.jasenia on 27/1/22.
//

import XCTest


class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromURL_createsDataTaskWithURL() {
        let url = URL(string: "http://any-url.com/")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(session.receivedURLs, [url])
    }
    
    func test_getFromURL_createsDataTaskWithURL_resumesOnce() {
        let url = URL(string: "http://any-url.com/")!
        let dataTask = URLSessionDataTaskSpy()
        let session = URLSessionSpy()
        session.stub(url: url, task: dataTask)
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(dataTask.resumeCallCount, 1)
    }
    
    //MARK: - Helpers
    private class URLSessionSpy: URLSession {
        var receivedURLs = [URL]()
        var stubs = [URL: URLSessionDataTask]()
        
        func stub(url: URL, task: URLSessionDataTask) {
            stubs[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            
            return stubs[url] ?? FakeURLSessionDataTask()
        }
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {}
    }
}
