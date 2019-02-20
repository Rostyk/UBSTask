//
//  GetAccountsRequest.swift
//  EquifyCRM
//
//  Created by Rostyslav Stepanyakon 7/6/18.
//  Copyright © 2018 Maliwan. All rights reserved.
//

import UIKit

struct GetSymbolsRequest: DDRequest {
}

extension GetSymbolsRequest: HTTPGetRequest {
    var urlQueryItems: [URLQueryItem]? {
        return nil
    }
    
    var additionalHeaders: [String: String]? {
        return nil
        //return ["Authorization": "Bearer " +  Keychain.getSgaredInstance().accessToken()]
    }
    
    var relativePath: String {
        return "/ref-data/symbols"
    }
}
