//
//  StockCell.swift
//  UBSDemo
//
//  Created by Ross Stepanyak on 2/19/19.
//  Copyright © 2018 Maliwan. All rights reserved.
//

import UIKit
class StockCell: UITableViewCell {
    @IBOutlet weak var symbolLabel: UILabel?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var changeLabel: UILabel?
    @IBOutlet weak var priceLabel: UILabel?
    @IBOutlet weak var favoriteImageView: UIImageView?
    
    func updateColors(forTrendValue: Float) {
        if forTrendValue == 0.0 {
            changeLabel?.textColor = UIColor.orange
        }
        else if forTrendValue < 0.0 {
            changeLabel?.textColor = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0)
        }
        else {
            changeLabel?.textColor = UIColor(red: 0.1, green: 0.8, blue: 0.1, alpha: 1.0)
        }
    }
}

