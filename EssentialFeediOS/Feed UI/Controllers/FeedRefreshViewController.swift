//
//  ViewController.swift
//  EssentialFeediOS
//
//  Created by james.jasenia on 15/3/2022.
//

import UIKit

final public class FeedRefreshViewController: NSObject, FeedLoadingView {
    private(set) lazy var view = loadView()
    private let presenter: FeedPresenter
        
    init(presenter: FeedPresenter) {
        self.presenter = presenter
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
        
    @objc func refresh() {
        presenter.loadFeed()
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}

