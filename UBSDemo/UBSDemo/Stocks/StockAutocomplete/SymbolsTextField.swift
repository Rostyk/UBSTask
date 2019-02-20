//
//  SymbolsTextView.swift
//  UBSDemo
//
//  Created by Rostyslav Stepanyakon 2/19/19.
//  Copyright © 2019 Ross Stepaniak. All rights reserved.
//

import UIKit

@objc protocol SymbolTextFieldDelegate {
    func showSymbol(_ symbol: String)
}

class SymbolsTextField: SearchTextField {
    
    fileprivate lazy var repository: Repository = {
        let repository = Repository.shared
        return repository
    }()
    
    @IBOutlet fileprivate weak var symbolsDelegate: SymbolTextFieldDelegate?
    public var symbols: [Symbol]? {
        didSet {
            reloadItems()
        }
    }
    fileprivate let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupDefaultAppearance()
        setupSelection()
        setupFavoriteDataSource()
    }
    
    /// MARK: selection handler
    
    fileprivate func setupSelection() {
        itemSelectionHandler = { [weak self] filteredResults, itemPosition in
            let item = filteredResults[itemPosition]
            self?.text = ""
            self?.resignFirstResponder()
            self?.symbolsDelegate?.showSymbol(item.title)
        }
    }
    
    /// MARK: favorite datasource
    
    fileprivate func setupFavoriteDataSource() {
        favoriteDatasource = self
    }
    
    /// MARK: default look/behaviour of the search field
    
    fileprivate func setupDefaultAppearance() {
        autocorrectionType = .no
        backgroundColor = UIColor(white: 0.89, alpha: 1.0)
        layer.cornerRadius = 5
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGray.cgColor
        clearButtonMode = UITextFieldViewMode.whileEditing
        
        theme = SearchTextFieldTheme.lightTheme()
        theme.font = UIFont.systemFont(ofSize: 14)
        theme.bgColor = UIColor (red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        theme.borderColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        theme.separatorColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 0.5)
        theme.cellHeight = 50
        
        placeholder = "Type in the stock symbol"
        comparisonOptions = [.caseInsensitive]
        maxNumberOfResults = 5
        maxResultsListHeight = 212
        
        highlightAttributes = [NSAttributedStringKey.backgroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: 14)!]
        
        startVisible = false
        startVisibleWithoutInteraction = false
        minCharactersNumberToStartFiltering = 2
        forceNoFiltering = false
    }
    
    fileprivate func reloadItems() {
        if let symbols = symbols {
            let items: [SearchTextFieldItem] = symbols.map ({ SearchTextFieldItem(title: $0.symbol, subtitle: $0.name, image: nil)})
            filterItems(items)
        }
    }
    
    
    /// MARK: add some padding
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}

/// MARK: checking already favorited items

extension SymbolsTextField: FavoriteDataSource {
    func isFavorite(_ symbol: String) -> Bool {
        return repository.isSymbolFavorited(symbol)
    }
}
