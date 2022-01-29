//
//  URLSessionHTTPClient.swift
//  EssentialFeedTests
//
//  Created by james.jasenia on 27/1/22.
//

import XCTest
import EssentialFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPClient {
    private let session: HTTPSession
    
    init(session: HTTPSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error { completion(.failure(error)) }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {    
    func test_getFromURL_createsDataTaskWithURL_resumesOnce() {
        let url = URL(string: "http://any-url.com/")!
        let dataTask = URLSessionDataTaskSpy()
        let session = HTTPSessionSpy()
        session.stub(url: url, task: dataTask)
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(dataTask.resumeCallCount, 1)
    }
    
    func test_getFromURL_returnsError_onSessionError() {
        let url = URL(string: "http://any-url.com/")!
        let expetectedError = NSError(domain: "", code: 0, userInfo: nil)
        
        let session = HTTPSessionSpy()
        session.stub(url: url, error: expetectedError)
        
        let sut = URLSessionHTTPClient(session: session)
        let exp = expectation(description: "Wait for completion")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, expetectedError)
            default:
                XCTFail("Expected \(expetectedError), got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Helpers
    private class HTTPSessionSpy: HTTPSession {
        var receivedURLs = [URL]()
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: HTTPSessionTask
            let error: NSError?
        }
        
        func stub(url: URL, task: HTTPSessionTask = FakeURLSessionDataTask(), error: NSError? = nil) {
            print("Tilly")
            stubs[url] = Stub(task: task, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
            receivedURLs.append(url)
            print(stubs.count)
            
            guard let stub = stubs[url] else {
                fatalError("Couldn't find stub for \(url)")
            }

            completionHandler(nil, nil, stub.error)
            
            
            return stub.task
        }
    }
    
    private class URLSessionDataTaskSpy: HTTPSessionTask {
        var resumeCallCount = 0
        
        func resume() {
            resumeCallCount += 1
        }
    }
    
    private class FakeURLSessionDataTask: HTTPSessionTask {
        func resume() {}
    }
}
