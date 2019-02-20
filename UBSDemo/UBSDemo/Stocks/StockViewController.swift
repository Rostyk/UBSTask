//
//  ViewController.swift
//  RevolutDemo
//
//  Created by Rostyslav Stepanyakon 1/29/19.
//  Copyright © 2019 Ross Stepaniak. All rights reserved.
//

import UIKit

class StockViewController: UIViewController {
    @IBOutlet fileprivate weak var symbolsTextfield: SymbolsTextField!
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var editButton: UIButton!
    
    fileprivate lazy var controller: StockController = {
        let controller = StockController()
        controller.presentable = self
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.setEmptyState(true)
        controller.fetchAllSymbols()
        controller.fetchFavoriteSymbols()
    }
    
    /// MARK: Edit button handler
    
    @IBAction fileprivate func editButtonClicked() {
        if tableView.isEditing {
            tableView.isEditing = false
            editButton.setTitle("Edit", for: .normal)
        }
        else {
            tableView.isEditing = true
            editButton.setTitle("Done", for: .normal)
        }
    }
}

///MARK: StockPresentable

extension StockViewController: StockPresentable {
    func reloadSymbols() {
        symbolsTextfield.symbols = controller.getLatestSymbols()
    }
    
    func reloadItems() {
        tableView.setEmptyState(controller.numerOfItems() == 0)
        editButton.isHidden = controller.numerOfItems() == 0
        tableView.reloadData()
    }
    
    func showError(_ errorText: String) {
        
    }
}

///MARK: Tableview datasource and delegate

extension StockViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.numerOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockCellReuseId") as! StockCell
        let item = controller.getStockItem(indexPath.row)
        cell.symbolLabel?.text = item.quote.symbol
        cell.nameLabel?.text = item.quote.companyName
        cell.changeLabel?.text = NSString(format: "%.2f%%", item.quote.changePercent) as String
        cell.priceLabel?.text = NSString(format: "%.2f", item.quote.latestPrice) as String
        cell.favoriteImageView?.image = item.isFavorite ? UIImage(named: "ic_favorite") : nil
        cell.updateColors(forTrendValue: item.quote.changePercent)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let stockItem = controller.getStockItem(editActionsForRowAt.row)
        let favorite = UITableViewRowAction(style: .normal, title: stockItem.isFavorite ? "Unlike" : "Like") { [weak self] action, index in
            self?.controller.favoriteItem(index.row)
        }
        favorite.backgroundColor = .orange
        return [favorite]
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        controller.swapItems(sourceIndexPath.row, destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

/// MARK: SymbolTextFieldPresentable

extension StockViewController: SymbolTextFieldDelegate {
    func showSymbol(_ symbol: String) {
        controller.fetchStockQuote(symbol)
    }
}

