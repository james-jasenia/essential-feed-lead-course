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
        
        descirptionLabel.text = model.description
        descirptionLabel.isHidden = model.description == nil
        
        fadeIn(UIImage(named: model.imageName))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        feedImageView.alpha = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        feedImageView.alpha = 0
    }
    
    func fadeIn(_ image: UIImage?) {
        feedImageView.image = image
        
        UIView.animate(withDuration: 0.3,
                       delay: 0.3,
                       options: [],
                       animations: { self.feedImageView.alpha = 1
            
        })
    }
}
