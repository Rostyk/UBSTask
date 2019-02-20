//
//  StockController.swift
//  UBSDemo
//
//  Created by Ross Stepanyak on 2/19/19.
//  Copyright © 2018 Maliwan. All rights reserved.
//

import Foundation

protocol StockPresentable: NSObjectProtocol {
    func reloadSymbols()
    func reloadItems()
    func showError(_ errorText: String)
}

class StockController: NSObject {
    fileprivate var stockItems = [StockItem]()
    fileprivate var symbols = [Symbol]()
    weak var presentable: StockPresentable?
    
    func fetchAllSymbols() {
        IEXAPI.shared.getSymbols { [weak self] (response, error) in
            if let response = response, let symbols = response.symbols {
                self?.symbols = symbols
                self?.presentable?.reloadSymbols()
            }
            else {
                self?.presentable?.showError((error?.errorDescription)!)
            }
        }
    }
    
    func fetchStockQuote(_ symbol: String) {
        IEXAPI.shared.getStockQuote(symbol: symbol) { [weak self] (response, error) in
            if let response = response, let quote = response.quote {
                let item = StockItem(quote: quote, isFavorite: false)
                
                if let existingItems = self?.stockItems {
                    if !existingItems.contains(where: { $0.quote.symbol == symbol }) {
                        self?.stockItems.append(item)
                        self?.presentable?.reloadItems()
                    }
                }
            }
            else {
                self?.presentable?.showError((error?.errorDescription)!)
            }
        }
    }
    
    func fetchFavoriteSymbols() {
        let favoriteItems = Repository.shared.allFavoriteItems()
        stockItems += favoriteItems
        
        if (stockItems.count > 0) {
            self.presentable?.reloadItems()
        }
    }
    
    /// MARK: Favorite action
    
    func favoriteItem(_ index: Int) {
        stockItems[index].isFavorite = !stockItems[index].isFavorite
        
        if stockItems[index].isFavorite {
            Repository.shared.saveFavoriteItem(stockItems[index])
        }
        else {
            Repository.shared.deleteFavoriteItem(stockItems[index])
        }
        
        self.stockItems.sort(by: { $0.isFavorite && !$1.isFavorite})
        self.presentable?.reloadItems()
    }
    
    /// MARK: Rearrange action
    
    func swapItems(_ source: Int, _ destination: Int) {
        let movedObject = stockItems[source]
        stockItems.remove(at: source)
        stockItems.insert(movedObject, at: destination)
    }
    
    /// MARK: Quotes datasource
    
    func getLatestSymbols() -> [Symbol] {
        return symbols
    }
    
    func getStockItem(_ index: Int) -> StockItem {
        return stockItems[index]
    }
    
    func numerOfItems() -> Int {
        return stockItems.count
    }
    
}
