//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by james.jasenia on 4/3/22.
//

import XCTest
import EssentialFeed

 extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
     func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         let deletionError = deleteCache(from: sut)

         XCTAssertNotNil(deletionError, "Expected cache deletion to fail", file: file, line: line)
     }

     func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         deleteCache(from: sut)

         expect(sut, toRetrieve: .empty, file: file, line: line)
     }
 }
