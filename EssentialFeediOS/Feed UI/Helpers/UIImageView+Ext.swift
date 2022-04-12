//
//  UIImageView+Ext.swift
//  EssentialFeediOS
//
//  Created by james.jasenia on 2/4/2022.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage
        
        guard newImage != nil else { return }
        
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
