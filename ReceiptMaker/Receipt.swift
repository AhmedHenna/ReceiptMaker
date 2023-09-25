//
//  Receipt.swift
//  ReceiptMaker
//
//  Created by Ahmed Henna on 9/25/23.
//

import Foundation


struct ReceiptItemDetails {
    var quantity: Int
    var extras: [String: Int]
}

func generateReceiptForKitchen(orderName: String, orderPrice: Double, tabdel: String, additionalMessage: String, arrivalTime: String, refundAmount: Double, tip: Double, items: [String], sizes: [String], mealDeals: [String], menuItemStore: MenuItemsStore) -> String {
    let companyName = "COMPANY NAME"
    let currentDate = getCurrentDate()
    let typeDetails = organizeItemsByTypeAndExtras(items: items, menuItemStore: menuItemStore)
    
    return createReceiptString(companyName: companyName, tabdel: tabdel, currentDate: currentDate, orderName: orderName, orderPrice: orderPrice, additionalMessage: additionalMessage, typeDetails: typeDetails, menuItemStore: menuItemStore)
}

func getCurrentDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormatter.string(from: Date()).uppercased()
}

func organizeItemsByTypeAndExtras(items: [String], menuItemStore: MenuItemsStore) -> [String: [String: ReceiptItemDetails]] {
    var typeDetails: [String: [String: ReceiptItemDetails]] = [:]

    for item in items {
        let components = item.components(separatedBy: ", Extras: ")
        if components.count > 0 {
            if let mainItemWithPrice = parseMainItemWithPrice(components: components, menuItemStore: menuItemStore) {
                let itemType = mainItemWithPrice.menuItem.type
                let mainItem = mainItemWithPrice.mainItem
                let extraItems = components.dropFirst()
                
                if typeDetails[itemType] == nil {
                    typeDetails[itemType] = [:]
                }
                
                if typeDetails[itemType]?[mainItem] == nil {
                    typeDetails[itemType]?[mainItem] = ReceiptItemDetails(quantity: 1, extras: [:])
                } else {
                    typeDetails[itemType]?[mainItem]?.quantity += 1
                }
                
                for extra in extraItems {
                    let extraName = extra.trimmingCharacters(in: .whitespaces)
                    if typeDetails[itemType]?[mainItem]?.extras[extraName] == nil {
                        typeDetails[itemType]?[mainItem]?.extras[extraName] = 1
                    } else {
                        typeDetails[itemType]?[mainItem]?.extras[extraName]? += 1
                    }
                }
            }
        }
    }
    
    return typeDetails
}

func parseMainItemWithPrice(components: [String], menuItemStore: MenuItemsStore) -> (mainItem: String, menuItem: MenuItem)? {
    guard components.count > 0 else { return nil }
    
    let mainItemWithPrice = components[0].trimmingCharacters(in: .whitespaces)
    let mainItemComponents = mainItemWithPrice.components(separatedBy: ":")
    
    guard mainItemComponents.count == 2 else { return nil }
    
    let mainItem = mainItemComponents[0].trimmingCharacters(in: .whitespaces)
    let priceComponents = mainItemComponents[1].components(separatedBy: "(")
    
    guard priceComponents.count == 2 else { return nil }
    
    let priceString = priceComponents[1].replacingOccurrences(of: ")", with: "").trimmingCharacters(in: .whitespaces)
    
    guard let price = Double(priceString), let menuItem = menuItemStore.items.first(where: { $0.name == mainItem }) else {
        return nil
    }
    print(price)
    
    return (mainItem, menuItem)
}

func createReceiptString(companyName: String, tabdel: String, currentDate: String, orderName: String, orderPrice: Double, additionalMessage: String, typeDetails: [String: [String: ReceiptItemDetails]], menuItemStore: MenuItemsStore) -> String {
    var receipt = """
    \(companyName)
    -----------------------------
    OrderType: \(tabdel)
    DATE: \(currentDate)
    ORDER NAME: \(orderName)
    -----------------------------
    """

    var totalOrderPrice: Double = 0.0

    for (itemType, itemDetails) in typeDetails {
        receipt += "\nType: \(itemType)\n"
        for (mainItem, details) in itemDetails {
            let menuItem = menuItemStore.items.first { $0.name == mainItem }
            guard let price = menuItem?.price else {
                continue
            }
            
            receipt += "\(mainItem) (\(price)) x \(details.quantity)\n"
            totalOrderPrice += Double(details.quantity) * price
            
            for (extraName, extraQuantity) in details.extras {
                receipt += "     \(extraName) x \(extraQuantity)\n"
            }
        }
    }

    receipt += """
    -----------------------------
    NOTE: \(additionalMessage.uppercased())
    POWERED BY AEXIR
    KITCHEN RECEIPT
    -----------------------------
    TOTAL: $\(totalOrderPrice)
    """
    
    return receipt
}


