//
//  ViewController.swift
//  EssentialFeediOS
//
//  Created by james.jasenia on 15/3/2022.
//

import UIKit

final public class FeedRefreshViewController: NSObject, FeedLoadingView {
    private(set) lazy var view = loadView()        
    private let loadFeed: () -> Void
    
    init(loadFeed: @escaping () -> Void) {
        self.loadFeed = loadFeed
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async {
                [weak self] in self?.display(viewModel)
            }
        }
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
        
    @objc func refresh() {
        loadFeed()
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}

