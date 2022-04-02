//
//  UITableView+Ext.swift
//  EssentialFeediOS
//
//  Created by james.jasenia on 2/4/2022.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return self.dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
