//
//  UItableView+EmptyState.swift
//  UBSDemo
//
//  Created by Rostyslav Stepanyakon 2/20/19.
//  Copyright © 2019 Ross Stepaniak. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit

extension UITableView {
    public func setEmptyState(_ state: Bool) {
        if state {
            let imageView = UIImageView(image: UIImage(named: "hg_default-loading"))
            
            let viewRect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.bounds.size.width, height: self.bounds.size.height))
            let labelRect = CGRect(origin: CGPoint(x: 0, y:viewRect.size.height / 2 + imageView.frame.size.height - 95), size: CGSize(width: self.bounds.size.width, height: 20))
            
            let view = UIView(frame: viewRect)
            let messageLabel = UILabel(frame: labelRect)
            messageLabel.text = "Start searching stocks!"
            messageLabel.textColor = UIColor(white: 0.07, alpha: 0.9)
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
            imageView.center = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2 - 63)
            imageView.tintColor = UIColor.lightGray
            view.alpha = 0.4
            view.addSubview(imageView)
            view.addSubview(messageLabel)
            
            separatorStyle = .none;
            backgroundView = view;
            
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 4
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 6, y: view.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 6, y: view.center.y))
            
            view.layer.add(animation, forKey: "position")
            
            tableHeaderView?.isHidden = true
        }
        else {
            tableHeaderView?.isHidden = false
            backgroundView = nil
        }
    }
}
