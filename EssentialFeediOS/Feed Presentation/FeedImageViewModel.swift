//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by james.jasenia on 28/3/2022.
//

import Foundation
import EssentialFeed

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}
