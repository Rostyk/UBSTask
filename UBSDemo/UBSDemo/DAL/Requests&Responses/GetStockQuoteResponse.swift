//
//  GetAccountsResponse.swift
//  EquifyCRM
//
//  Created by Rostyslav Stepanyakon 7/6/18.
//  Copyright © 2018 Maliwan. All rights reserved.
//

import Foundation

struct GetStockQuoteResponse: DDResponse {
    var quote: StockQuote?
}

extension GetStockQuoteResponse: Deserializable {
    init?(data: Data) {
        guard let pasredQuote = try? JSONDecoder().decode(StockQuote.self, from: data) else { return nil }
        quote = pasredQuote
    }
}
