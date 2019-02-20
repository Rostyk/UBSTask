//
//  UBSNetworkingTests.swift
//  UBSDemoTests
//
//  Created by Rostyslav Stepanyak on 2/20/19.
//  Copyright © 2019 Ross Stepaniak. All rights reserved.
//

import XCTest

class UBSDemoNetworkingTests: XCTestCase {
    private var validSymbolExpectation = XCTestExpectation()
    private var validQuoteExpectation = XCTestExpectation()
    
    private var incorrectSymbolExpectation = XCTestExpectation()
    private var incorrectQuoteExpectation = XCTestExpectation()
    private let symbols:[String] = ["CATB", "XXX"]
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSuccessSymbolsAPI() {
        IEXAPI.shared.getSymbols { [weak self] (response, error) in
            self?.validSymbolExpectation.fulfill()
            
            XCTAssertNil(error, "Could not complete request")
            XCTAssertNotNil(response, "Could not get proper response")
            
            if let response = response {
                if let symbolsCount = response.symbols?.count {
                    XCTAssert(symbolsCount > 0, "Could not get any currency rates")
                    
                    if let item = response.symbols?.first {
                        let shortName = item.symbol
                        let name = item.name
                        
                        XCTAssert(shortName.count > 0, "Symbol code should be a valid string")
                        XCTAssert(name.count > 0, "Company name should be a valid string")
                    }
                }
            }
        }
        
        wait(for: [validSymbolExpectation], timeout: 4.0)
   }
    
    func testQuotesAPI() {
        IEXAPI.shared.getStockQuote(symbol: symbols[0]) { [weak self] (response, error) in
            self?.validQuoteExpectation.fulfill()
            
            XCTAssertNil(error, "Could not complete request")
            XCTAssertNotNil(response, "Could not get proper response")
            
            if let response = response {
                if let quote = response.quote {
                    XCTAssert(quote.symbol.count > 0, "Symbol should be a valid string")
                    XCTAssert(quote.companyName.count > 0, "Company name should be a valid string")
                    XCTAssert(quote.latestPrice <= 0, "Latest price should be valid")
                }
            }
        }
        
        wait(for: [validQuoteExpectation], timeout: 4.0)
    }
    
    func testFailureQuotesAPI() {
        IEXAPI.shared.getStockQuote(symbol: symbols[1]) { [weak self] (response, error) in
            self?.incorrectQuoteExpectation.fulfill()
            
            if let error = error {
                XCTAssertNotNil(error, "Error should carry some information. Should not be nil")
                XCTAssert(error.code == 404, "Status should be: Not Found") // according to IEX spec
                XCTAssertNil(response, "Should be nil as the request failed")
            }
            
        }
        
        wait(for: [incorrectQuoteExpectation], timeout: 4.0)
    }
    
   func testFailureSymbolsAPI() {
        IEXAPI.shared.getSymbols { [weak self] (response, error) in
            self?.incorrectSymbolExpectation.fulfill()
            
            if let error = error {
                XCTAssertNotNil(error, "Error should carry some information. Should not be nil")
                XCTAssert(error.code == 423, "Status should be: Unprocessible entity")
                XCTAssertNil(response, "Should be nil as the request failed")
            }
            
        }
        wait(for: [incorrectSymbolExpectation], timeout: 4.0)
    }
}
