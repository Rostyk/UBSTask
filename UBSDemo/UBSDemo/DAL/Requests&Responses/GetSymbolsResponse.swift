//
//  GetAccountsResponse.swift
//  EquifyCRM
//
//  Created by Rostyslav Stepanyakon 7/6/18.
//  Copyright © 2018 Maliwan. All rights reserved.
//

import Foundation

struct GetSymbolsResponse: DDResponse {
    var symbols: [Symbol]?
}

extension GetSymbolsResponse: Deserializable {
    init?(data: Data) {
        guard let parsedSymbols = try? JSONDecoder().decode([Symbol].self, from: data) else { return nil }
        symbols = parsedSymbols
    }
}
