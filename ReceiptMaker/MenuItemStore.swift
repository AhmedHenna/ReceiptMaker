//
//  MenuItemStore.swift
//  ReceiptMaker
//
//  Created by Ahmed Henna on 9/25/23.
//

import Foundation
import SwiftUI
import Firebase

class MenuItemsStore: ObservableObject {
    @Published var items: [MenuItem] = []
    @State var ingredients: [Ingredient] = []
    
    func fetchMenuItems() {
        let db = Firestore.firestore()
        let menuItemsRef = db.collection("menu")
        let changesRef = db.collection("changes").document("menu")
        
        // Initialize read request counter
        var readRequestCounter = 0
        
        // Get the last updated time for the menu from Firestore
        readRequestCounter += 1
        changesRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let lastUpdateTime = document.data()?["time"] as? String ?? ""
                
                // Get the last updated time for the menu from UserDefaults
                let defaults = UserDefaults.standard
                let menuTime = defaults.object(forKey: "menuTime") as? String
                
                if let menuTime = menuTime, menuTime == lastUpdateTime {
                    // If the menu is up to date, use documents from the cache
                    readRequestCounter += 1
                    menuItemsRef.getDocuments(source: .cache) { (snapshot, error) in
                        if let error = error {
                            print("Error getting documents from cache: \(error)")
                        } else if let snapshot = snapshot, !snapshot.documents.isEmpty {
                            // If there are documents in the cache, use them
                            let fromCache = snapshot.metadata.isFromCache
                            self.items = snapshot.documents.map { document in
                                let data = document.data()
                                let name = data["Name"] as! String
                                let price = data["Price"] as! Double
                                let image = data["Image"] as! String
                                let description = data["Description"] as! String
                                let ingredientNames = data["ingredients"] as! [String]
                                let type = data["type"] as? String ?? "Error"
                                let location = data["location"] as? String ?? "Error"
                                let lastUpdate = data["time"] as? Timestamp ?? Timestamp()
                                let mealDeal = data["mealDeal"] as! String
                                let mdPrice = data["mdPrice"] as! Double
                                let sizeArray = data["size"] as! [String]
                                let sizePriceArray = data["sizePrice"] as! [Double]
                                
                                let ingredients = ingredientNames.compactMap { ingredientName in
                                    return self.ingredients.first { ingredient in
                                        ingredient.name == ingredientName
                                    }
                                }
                                
                                let drinksArray = data["drink"] as! [String]
                                let sidesArray = data["side"] as! [String]
                                let selectedVAT = data["SelectedVAT"] as? Double ?? 0
                                
                                let fetchedFrom = fromCache ? "cache" : "server"
                                print("Fetched menu items from: \(fetchedFrom)")
                                return MenuItem(name: name, price: price, image: image, description: description, ingredients: ingredients, type: type, location: location, mealDeal: mealDeal, drinks: drinksArray, sides: sidesArray, mdPrice: mdPrice, size: sizeArray, sizePrice: sizePriceArray, lastUpdate: lastUpdate, SelectedVAT: selectedVAT)
                            }
                            print("Fetched menu items from cache. Total read requests: \(readRequestCounter)")
                            print("Menu Items in Store:")
                            for item in self.items {
                                print(item.name, " : ", item.type, " : ", item.price)
                            }
                        } else {
                            // If there are no documents in the cache, fetch them from the server
                            readRequestCounter += 1
                            menuItemsRef.getDocuments(source: .server) { (snapshot, error) in
                                if let error = error {
                                    print("Error getting documents from server: \(error)")
                                } else {
                                    let fromCache = snapshot!.metadata.isFromCache
                                    self.items = snapshot!.documents.map { document in
                                        let data = document.data()
                                        let name = data["Name"] as! String
                                        let price = data["Price"] as! Double
                                        let image = data["Image"] as! String
                                        let description = data["Description"] as! String
                                        let ingredientNames = data["ingredients"] as! [String]
                                        let type = data["type"] as? String ?? "Error"
                                        let location = data["location"] as? String ?? "Error"
                                        let lastUpdate = data["time"] as? Timestamp ?? Timestamp()
                                        let mealDeal = data["mealDeal"] as! String
                                        let mdPrice = data["mdPrice"] as! Double
                                        let sizeArray = data["size"] as! [String]
                                        let sizePriceArray = data["sizePrice"] as! [Double]
                                        let selectedVAT = data["SelectedVAT"] as? Double ?? 0
                                        
                                        let ingredients = ingredientNames.compactMap { ingredientName in
                                            return self.ingredients.first { ingredient in
                                                ingredient.name == ingredientName
                                            }
                                        }
                                        
                                        let drinksArray = data["drink"] as! [String]
                                        let sidesArray = data["side"] as! [String]
                                        
                                        let fetchedFrom = fromCache ? "cache" : "server"
                                        print("Fetched menu items from: \(fetchedFrom)")
                                        return MenuItem(name: name, price: price, image: image, description: description, ingredients: ingredients, type: type, location: location, mealDeal: mealDeal, drinks: drinksArray, sides: sidesArray, mdPrice: mdPrice, size: sizeArray, sizePrice: sizePriceArray, lastUpdate: lastUpdate, SelectedVAT: selectedVAT)
                                    }
                                }
                                print("Fetched menu items from server. Total read requests: \(readRequestCounter)")
                                print("Menu Items in Store:")
                                for item in self.items {
                                    print(item.name, " : " , item.type, " : ", item.price)
                                }
                            }
                        }
                    }
                } else {
                    // If the menu is not up to date, fetch new documents from the server
                    readRequestCounter += 1
                    menuItemsRef.getDocuments(source: .server) { (snapshot, error) in
                        if let error = error {
                            print("Error getting documents from server: \(error)")
                        } else {
                            let fromCache = snapshot!.metadata.isFromCache
                            self.items = snapshot!.documents.map { document in
                                let data = document.data()
                                let name = data["Name"] as! String
                                let price = data["Price"] as! Double
                                let image = data["Image"] as! String
                                let description = data["Description"] as! String
                                let ingredientNames = data["ingredients"] as! [String]
                                let type = data["type"] as? String ?? "Error"
                                let location = data["location"] as? String ?? "Error"
                                let lastUpdate = data["time"] as? Timestamp ?? Timestamp()
                                let mealDeal = data["mealDeal"] as! String
                                let mdPrice = data["mdPrice"] as! Double
                                let sizeArray = data["size"] as! [String]
                                let sizePriceArray = data["sizePrice"] as! [Double]
                                let selectedVAT = data["SelectedVAT"] as? Double ?? 0
                                
                                let ingredients = ingredientNames.compactMap { ingredientName in
                                    return self.ingredients.first { ingredient in
                                        ingredient.name == ingredientName
                                    }
                                }
                                
                                let drinksArray = data["drink"] as! [String]
                                let sidesArray = data["side"] as! [String]
                                
                                let fetchedFrom = fromCache ? "cache" : "server"
                                print("Fetched menu items from: \(fetchedFrom)")
                                return MenuItem(name: name, price: price, image: image, description: description, ingredients: ingredients, type: type, location: location, mealDeal: mealDeal, drinks: drinksArray, sides: sidesArray, mdPrice: mdPrice, size: sizeArray, sizePrice: sizePriceArray, lastUpdate: lastUpdate, SelectedVAT: selectedVAT)
                            }
                            
                            // Update UserDefaults with the new menu update time
                            defaults.set(lastUpdateTime, forKey: "menuTime")
                        }
                        print("Fetched menu items from server. Total read requests: \(readRequestCounter)")
                        print("Menu Items in Store:")
                        for item in self.items {
                            print(item.name, " : ", item.type, " : ", item.price)
                        }
                    }
                }
            }
        }
    }
}


class MenuItem: Identifiable, Equatable, ObservableObject, Encodable {
    var id = UUID()
    var name: String
    var price: Double
    var image: String
    var description: String
    var ingredients: [Ingredient]
    var type: String
    var location: String
    var mealDeal: String
    var drinks: [String]
    var sides: [String]
    var mdPrice: Double
    var size: [String]
    var sizePrice: [Double]
    var lastUpdate: Timestamp = Timestamp()
    var SelectedVAT: Double
    var dictionary: [String: Any] {
        return ["name": name, "price": price, "image": image, "description": description, "ingredients": ingredients.map { $0.name }, "type": type, "location": location, "mealDeal": mealDeal, "sides": sides,"drinks": drinks, "mdPrice":mdPrice, "size": size, "sizePrice": sizePrice, "lastUpdate": lastUpdate,"VAT": SelectedVAT]}
    
    static func == (lhs: MenuItem, rhs: MenuItem) -> Bool {
        return lhs.id == rhs.id
        
    }
    
    init(name: String, price: Double, image: String, description: String, ingredients: [Ingredient], type: String, location: String, mealDeal: String, drinks: [String], sides: [String], mdPrice: Double, size: [String], sizePrice: [Double], lastUpdate: Timestamp, SelectedVAT: Double) {
        self.name = name
        self.price = price
        self.image = image
        self.description = description
        self.ingredients = ingredients
        self.type = type
        self.location = location
        self.mealDeal = mealDeal
        self.drinks = drinks
        self.sides = sides
        self.mdPrice = mdPrice
        self.size = size
        self.sizePrice = sizePrice
        self.lastUpdate = lastUpdate
        self.SelectedVAT = SelectedVAT
    }
    
}

struct Ingredient: Hashable, Encodable, Identifiable {
    var name: String
    var price: Double
    var description: String
    var time: Timestamp = Timestamp()
    var id: String
    var isToggled: Bool = false
    var vatPercentage: Double = 0.0 // New property for VAT percentage
    
    
    enum CodingKeys: String, CodingKey {
        case name, price, description, time, id, isToggled, vatPercentage // Include vatPercentage in CodingKeys
        
    }
    
    init(name: String, price: Double, description: String, time: Timestamp, id: String, isToggled: Bool, vatPercentage: Double = 0.0) {
        self.name = name
        self.price = price
        self.description = description
        self.time = time
        self.id = id
        self.isToggled = isToggled
        self.vatPercentage = vatPercentage
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(price, forKey: .price)
        try container.encode(description, forKey: .description)
        try container.encode(time, forKey: .time)
        try container.encode(id, forKey: .id)
        try container.encode(isToggled, forKey: .isToggled)
        try container.encode(vatPercentage, forKey: .vatPercentage) // Encode vatPercentage
        }
}

extension Timestamp: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.dateValue()) // Assuming dateValue() returns a Date
    }
}

