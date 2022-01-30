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
        
        URLProtocolStub.stub(data: nil, response: nil, error: expetectedError)
        
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
        private static var stub: Stub?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: NSError?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: NSError?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
        }
                
        override class func canInit(with request: URLRequest) -> Bool {
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
