//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by james.jasenia on 23/1/22.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    
    ///The completion handler can be invoked in any thread.
    ///Clients are responsible for dispatching to the approparite threads.
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
