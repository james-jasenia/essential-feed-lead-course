//
//  FeedImageCell.swift
//  Prototype
//
//  Created by james.jasenia on 7/3/22.
//

import UIKit

final class FeedImageCell: UITableViewCell {
    @IBOutlet private(set) var locationContainer: UIView!
    @IBOutlet private(set) var locationLabel: UILabel!
    @IBOutlet private(set) var feedImageView: UIImageView!
    @IBOutlet private(set) var descirptionLabel: UILabel!
    
    func configure(with model: FeedImageViewModel) {
        locationLabel.text = model.location
        locationContainer.isHidden = model.location == nil
        
        feedImageView.image = UIImage(named: model.imageName)
        
        descirptionLabel.text = model.description
        descirptionLabel.isHidden = model.description == nil
    }
}
