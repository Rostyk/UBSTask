//
//  DDEquifyAPI.swift
//  RevoluteDemo
//
//  Created by Ross Stepaniak on 6/25/18.
//  Copyright © 2018 Maliwan. All rights reserved.
//

import UIKit

class IEXAPI: NSObject {
    private lazy var transport: DDRequestService? = {
        let version = 1.0
        let baseUrlURL = "https://api.iextrading.com/\(version)"
        let transport = DDRequestHTTPService(baseUrl: URL(string: baseUrlURL)!)
        return transport
    }()
    
    static let shared = IEXAPI()
    private override init() { }
    
    public func getStockQuote(symbol: String, completion: @escaping (GetStockQuoteResponse?, TransportError?) -> Void) {
        let getStockQuoteReqeust = GetStockQuoteRequest(symbol: symbol)
        transport?.send(request: getStockQuoteReqeust) {
            (response: GetStockQuoteResponse?, error: TransportError?) in
            if let response = response {
                if let _ = response.quote {
                    completion(response, nil)
                } else {
                    completion(nil, TransportError.DeserializationFailed)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    public func getSymbols(completion: @escaping (GetSymbolsResponse?, TransportError?) -> Void) {
        let getSymbolsReqeust = GetSymbolsRequest()
        transport?.send(request: getSymbolsReqeust) {
            (response: GetSymbolsResponse?, error: TransportError?) in
            if let response = response {
                if let _ = response.symbols {
                    completion(response, nil)
                } else {
                    completion(nil, TransportError.DeserializationFailed)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    
}
