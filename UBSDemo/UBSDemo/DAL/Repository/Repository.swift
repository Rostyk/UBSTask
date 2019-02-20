//
//  Repository.swift
//  UBSDemo
//
//  Created by Rostyslav Stepanyakon 2/20/19.
//  Copyright © 2019 Ross Stepaniak. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Repository {
    static let shared = Repository()
    
    /// MARK: Persistant container setup
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        /* Should have integrated sqlcypher with common crypto and perhaps NSFileProtection key logic
         * As of know lets use plain text sqlite
         
        let container = NSPersistentContainer(name: "DbModel")
        let cOpts : NSDictionary = [
            EncryptedStore.optionPassphraseKey() : "XXXXSOME_BLOB_KEYXXXXXX",
            EncryptedStore.optionFileManager() : EncryptedStoreFileManager.default()
        ]
        let desc = try! EncryptedStore.makeDescription(options: cOpts as! [AnyHashable : Any], configuration: nil)
        container.persistentStoreDescriptions = [desc]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })*/
        
        let container = NSPersistentContainer(name: "UBSDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    /// MARK: Basic CRUD for favorite stock items / quotes
    
    func saveFavoriteItem(_ stockItem: StockItem) {
        let managedContext = Repository.shared.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "FavoriteItem", in: managedContext)!
        let item = NSManagedObject(entity: entity, insertInto: managedContext)
        item.setValue(stockItem.quote.companyName, forKeyPath: "companyName")
        item.setValue(stockItem.quote.symbol, forKeyPath: "symbol")
        item.setValue(stockItem.quote.changePercent, forKeyPath: "changePercent")
        item.setValue(stockItem.quote.latestPrice, forKeyPath: "latestPrice")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func allFavoriteItems() -> [StockItem]{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteItem")
        request.returnsObjectsAsFaults = false
        do {
            let result = try Repository.shared.persistentContainer.viewContext.fetch(request)
            let attachedEntities = result as! [FavoriteItem]
            let detachedEntities = attachedEntities.map {(element) in
                let quote = StockQuote(symbol: element.symbol!,
                                       companyName: element.companyName!,
                                       latestPrice: element.latestPrice,
                                       changePercent: element.changePercent)
                
                return StockItem(quote: quote, isFavorite: true)
            } as [StockItem]
            
            return detachedEntities
        } catch {
            print("Fetching existing items for symbol failed")
        }
        
        do {
            try Repository.shared.persistentContainer.viewContext.save()
        } catch let error as NSError {
            print("Could not save after deleting symbol. \(error), \(error.userInfo)")
        }
        
        return []
    }
    
    func deleteFavoriteItem(_ item: StockItem){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteItem")
        request.predicate = NSPredicate(format: "symbol = %@", "\(item.quote.symbol)")
        request.returnsObjectsAsFaults = false
        do {
            let result = try Repository.shared.persistentContainer.viewContext.fetch(request)
            for item in result as! [FavoriteItem] {
                Repository.shared.persistentContainer.viewContext.delete(item)
            }
            
        } catch {
            print("Fetching existing items for symbol failed")
        }
        
        do {
            try Repository.shared.persistentContainer.viewContext.save()
        } catch let error as NSError {
            print("Could not save after deleting symbol. \(error), \(error.userInfo)")
        }
    }
    
    func isSymbolFavorited(_ symbol: String) -> Bool{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteItem")
        request.predicate = NSPredicate(format: "symbol = %@", "\(symbol)")
        request.returnsObjectsAsFaults = false
        do {
            let result = try Repository.shared.persistentContainer.viewContext.fetch(request)
            if (result.count > 0) {
                return true
            }
        } catch {
            print("Fetching existing items for symbol failed")
        }
        
        return false
    }
    
    /// MARK: saving logic
    
    fileprivate func saveContext() {
        let context = Repository.shared.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    private init() {}
}
