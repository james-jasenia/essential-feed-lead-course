//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by james.jasenia on 19/2/22.
//

import Foundation
import EssentialFeed

func anyNSError() -> NSError {
    return NSError(domain: "", code: 0, userInfo: nil)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com/")!
}
