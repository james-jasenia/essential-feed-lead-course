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
    func test_getFromURL_returnsError_onSessionError() {
        
        URLProtocolStub.startInterceptingRequests()
        
        let url = URL(string: "http://any-url.com/")!
        let expetectedError = NSError(domain: "", code: 0, userInfo: nil)
        
        URLProtocolStub.stub(url: url, error: expetectedError)
        
        let sut = URLSessionHTTPClient()
        let exp = expectation(description: "Wait for completion")
        
        sut.get(from: url) { result in
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
        
        URLProtocolStub.stopInterceptingRequests()
    }
    
    //MARK: - Helpers
    private class URLProtocolStub: URLProtocol {
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            let error: NSError?
        }
        
        static func stub(url: URL, error: NSError? = nil) {
            stubs[url] = Stub(error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = [:]
        }
        
        //If we return true, it means that we can handle this request and it is our responsibility to complete with either success or failure. We have intercepted this request and we have control over it's fate. A live network call is no longer being made.
        
        //Because canInit is called as a class method, which means we don't have an instance of this class yet. The only way to access the methods and properties needed in this method is to make them static.
        override class func canInit(with request: URLRequest) -> Bool {
            
            //If we don't have a url for the request, we can't handle the request
            guard let url = request.url else { return false }
            
            //Will return true if we have a url, or it will return false if we don't. I am tempted to put another guard let and throw a fatal error as the developer has forgotten to stub the url in the test.
            return URLProtocolStub.stubs[url] != nil
        }
        
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            //request is an instance property of the URLProtocol class.
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
        
        //Subclassing you need to override this method otherwise you will get a crash.
        override func stopLoading() {}
    }
    
}
