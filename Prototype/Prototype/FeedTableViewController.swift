//
//  FeedViewController.swift
//  Prototype
//
//  Created by james.jasenia on 7/3/22.
//

import UIKit

class FeedTableViewController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "FeedImageCell", for: indexPath)
    }
    
}
