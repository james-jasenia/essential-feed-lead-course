//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by james.jasenia on 16/1/22.
//

import XCTest
import EssentialFeed

class LoadFeedFromRemoteUseCastTests: XCTestCase {
    
    func test_HTTPClientInit_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "http://www.any-url.com/")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURL() {
        let url = URL(string: "http://www.any-url.com/")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: failure(.connectivity)) {
            let clientError = NSError(domain: "test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponseWithEmptyJSON() {
        let (sut, client) = makeSUT()
    
        let samples = [0, 199, 201, 300, 400, 500]
   
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: failure(.invalidData)) {
                let json = makeJSONPayload([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: failure(.invalidData)) {
            let invalidJSON = Data("invalidJSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .success([])) {
            //Probably could have used JSONSerialisation here to make the test conventions more consistent
            let emptyJSON = makeJSONPayload([])
            client.complete(withStatusCode: 200, data: emptyJSON)
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let (item1, json1) = makeItem(
            id: UUID(),
            imageURL: URL(string: "http://any-url.com/")!
        )
        
        let (item2, json2) = makeItem(
            id: UUID(),
            description: "any description",
            location: "any location",
            imageURL: URL(string: "http://any-url.com/")!)
        
        expect(sut, toCompleteWithResult: .success([item1, item2])) {
            let json = makeJSONPayload([json1, json2])
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    func test_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://www.any-url.com/")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResult = [RemoteFeedLoader.Result]()
        sut?.load { capturedResult.append($0) }

        sut = nil        
        
        client.complete(withStatusCode: 200, data: makeJSONPayload([]))
        
        XCTAssertTrue(capturedResult.isEmpty)
    }

    
    //MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "http://www.any-url.com/")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut =  RemoteFeedLoader(url: url, client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
    
    func expect(_ sut: RemoteFeedLoader, toCompleteWithResult expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Waiting for completion")
        
        sut.load { capturedResult in
            switch (capturedResult, expectedResult) {
            case let (.success(capturedData), .success(expectedData)):
                XCTAssertEqual(capturedData, expectedData, file: file, line: line)
            case let (.failure(capturedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(capturedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(capturedResult) instead.")
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: String]) {
        
        let item = FeedImage(
            id: id,
            description: description,
            location: location,
            url: imageURL
        )
        
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }
        
        return (item, json)
    }
    
    private func makeJSONPayload(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    //MARK: - Spies
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            
            messages[index].completion(.success(data, response))
        }
    }
}
