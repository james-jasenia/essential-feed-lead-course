//
//  ViewController.swift
//  EssentialFeediOS
//
//  Created by james.jasenia on 15/3/2022.
//

import UIKit

final public class FeedRefreshViewController: NSObject {
    
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        bind(view)
        return view
    }()
    
    private let viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
        
    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    private func bind(_ view: UIRefreshControl) {
        //Binds the ViewModel with the View
        viewModel.onChange = { [weak self] viewModel in
            if viewModel.isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
        }
        
        //Binds the View with the ViewModel
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
}

