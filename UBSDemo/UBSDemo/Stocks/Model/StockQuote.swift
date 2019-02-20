//
//  StockQuote.swift
//  UBSDemo
//
//  Created by Rostyslav Stepanyakon 2/19/19.
//  Copyright © 2019 Ross Stepaniak. All rights reserved.
//

import Foundation

struct StockQuote: Decodable {
    var symbol: String
    var companyName: String
    var latestPrice: Float
    var changePercent: Float
}
