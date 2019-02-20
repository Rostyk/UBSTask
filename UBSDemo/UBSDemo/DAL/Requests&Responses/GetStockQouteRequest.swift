//
//  GetAccountsRequest.swift
//  EquifyCRM
//
//  Created by Rostyslav Stepanyakon 7/6/18.
//  Copyright © 2018 Maliwan. All rights reserved.
//

import UIKit

struct GetStockQuoteRequest: DDRequest {
    var symbol: String
}

extension GetStockQuoteRequest: HTTPGetRequest {
    var urlQueryItems: [URLQueryItem]? {
        //return [URLQueryItem(name: "symbol", value: symbol)]
        return nil
    }
    
    var additionalHeaders: [String: String]? {
        return nil
        //return ["Authorization": "Bearer " +  Keychain.getSgaredInstance().accessToken()]
    }
    
    var relativePath: String {
        return "/stock/\(symbol)/quote"
    }
}
