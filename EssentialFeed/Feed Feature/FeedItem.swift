//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by james.jasenia on 16/1/22.
//

import Foundation

public struct FeedItem: Equatable, Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
