//
//  URLSessionHTTPClient.swift
//  EssentialFeedTests
//
//  Created by james.jasenia on 27/1/22.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error { completion(.failure(error)) }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()

    }
    
    func test_getFromURL_performsGetRequestWithURL() {
        
        let url = URL(string: "http://any-url.com/")!
        let exp = expectation(description: "Waiting for request completion")
       
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_returnsError_onSessionError() {
        let url = URL(string: "http://any-url.com/")!
        let expetectedError = NSError(domain: "", code: 0, userInfo: nil)
        URLProtocolStub.stub(data: nil, response: nil, error: expetectedError)
        
        let exp = expectation(description: "Wait for get completion")
        
        makeSUT().get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, expetectedError.domain)
                XCTAssertEqual(receivedError.code, expetectedError.code)
            default:
                XCTFail("Expected \(expetectedError), got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var capturedRequestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: NSError?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: NSError?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            capturedRequestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            capturedRequestObserver = nil
        }
                
        override class func canInit(with request: URLRequest) -> Bool {
            
            //Everytime a request is intiated we can invoke the observer passing the request
            capturedRequestObserver?(request)
            
            //We are always intercenpting the requests now, therefore, we are never actually hitting the network now.
            return true
        }
        
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
        
        override func stopLoading() {}
    }
    
}
