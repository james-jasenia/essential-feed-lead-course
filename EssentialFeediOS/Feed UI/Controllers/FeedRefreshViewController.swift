//
//  ViewController.swift
//  EssentialFeediOS
//
//  Created by james.jasenia on 15/3/2022.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final public class FeedRefreshViewController: NSObject, FeedLoadingView {
    @IBOutlet private var view: UIRefreshControl?
    var delegate: FeedRefreshViewControllerDelegate?
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view?.beginRefreshing()
        } else {
            view?.endRefreshing()
        }
    }
        
    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }
}

