[Demo video link](https://www.youtube.com/watch?v=UZKqO4QLrj8)
### View side of things.
#### As simple as classic MVC. Could have added few interactors for networking and presenters to be more solid.

```swift

....
let controller = StockController()
controller.presentable = self
....

....
extension YourViewController: StockPresentable {
     func reloadSymbols() {
        
    }
    
    func reloadItems() {
        /* Do something like
        tableView.reloadData()
        */
    }
    
    func showError(_ errorText: String) {
        
    }
}

```

### API side of things:

"Networking engine" folder contains a very simple HTTP transport. Every request and response come as separate file.


#### API call invokation logic:

```swift
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
```

#### API wrapper. All time favourite singleton :) Could be something more elegant ofcourse. Like interactors to be more VIPER-ish.

```swift
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
```

#### Parsing logic uses Decodeable approach

```swift
struct GetStockQuoteResponse: DDResponse {
    var quote: StockQuote?
}

extension GetStockQuoteResponse: Deserializable {
    init?(data: Data) {
        guard let pasredQuote = try? JSONDecoder().decode(StockQuote.self, from: data) else { return nil }
        quote = pasredQuote
    }
}

```

## Tests

```swift
// NetworkingTests.swift contain some simple unit tests:

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

```

## Secure Core Data
#### It would require overriding persitant store coordinator with encrypted coordinator (sqlcypher and common crypto would work).
- NSFileProtection is preferrable to lock any paths/files with docs or any sensitive data. 
- Perhaps Keychain for some of the credntials (in case we used some athentication mechanisms) 

Very simple piece of code (it's not actually in the app)
```swift
let container = NSPersistentContainer(name: "UBSDemo")
let cypherOptions : NSDictionary = [
   EncryptedStore.optionPassphraseKey() : "XXXXSOME_BLOB_KEYXXXXXX",
   EncryptedStore.optionFileManager() : EncryptedStoreFileManager.default()
]
let desc = try! EncryptedStore.makeDescription(options: cypherOptions as! [AnyHashable : Any], configuration: nil)
container.persistentStoreDescriptions = [desc]
container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // error would give you a hint about why persitant store can't be created
            }
})
```
