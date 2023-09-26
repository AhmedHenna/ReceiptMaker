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
    
   let itemDetails = createItemsDetailsDictionary(items: items, menuItemStore: menuItemStore)
    
    let receipt = createReceiptString(companyName: companyName, tabdel: tabdel, currentDate: currentDate, orderName: orderName, additionalMessage: additionalMessage, itemDetails: itemDetails, menuItemStore: menuItemStore)

   return receipt
}

func getCurrentDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormatter.string(from: Date()).uppercased()
}

func createItemsDetailsDictionary(items: [String], menuItemStore: MenuItemsStore) -> [String: [ReceiptItemDetails]]{
    // Create a dictionary to group items by name
    var itemDetails: [String: [ReceiptItemDetails]] = [:]

    for item in items {
        if let (mainItem, menuItem) = parseMainItemWithPrice(components: item.components(separatedBy: ", Extras: "), menuItemStore: menuItemStore) {
            if itemDetails[mainItem] == nil {
                itemDetails[mainItem] = []
            }

            // Process extras for each item
            let extraItems = item.components(separatedBy: ", Extras: ").dropFirst()
            var extras: [String: Int] = [:]
            for extra in extraItems {
                let extraName = trimStringAfterFirstParenthesis(extra.trimmingCharacters(in: .whitespaces))
                extras[extraName] = (extras[extraName] ?? 0) + 1
            }

            itemDetails[mainItem]?.append(ReceiptItemDetails(quantity: 1, extras: extras))
        }
    }
    return itemDetails
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
    
    return (mainItem, menuItem)
}

func createReceiptString(companyName: String, tabdel: String, currentDate: String, orderName: String, additionalMessage: String, itemDetails: [String: [ReceiptItemDetails]], menuItemStore: MenuItemsStore) -> String {

    var receipt = """
    \(companyName)
    -----------------------------
    OrderType: \(tabdel)
    DATE: \(currentDate)
    ORDER NAME: \(orderName)
    -----------------------------
    """

    var itemsByType: [String: [String]] = [:]

    itemsByType = groupItemsByCategory(itemDetails: itemDetails, menuItemStore: menuItemStore)

    let customCategoryOrder = ["Starter", "Main", "Side", "Drink"]
    
    let sortedItemsByType = sortItemsByCustomOrder(itemsByType: itemsByType, customCategoryOrder: customCategoryOrder)
    
    appendCategoriesToReceipt(receipt: &receipt, sortedItemsByType: sortedItemsByType)
    
    appendAdditionalInfoToReceipt(receipt: &receipt, additionalMessage: additionalMessage)

    return receipt
}

func groupItemsByCategory(itemDetails: [String: [ReceiptItemDetails]], menuItemStore: MenuItemsStore) -> [String: [String]] {
    var itemsByType: [String: [String]] = [:]

    for (mainItem, detailsArray) in itemDetails {
        let menuItem = menuItemStore.items.first { $0.name == mainItem }
        guard let type = menuItem?.type else {
            continue
        }

        let category = customCategory(fromType: type)

        if itemsByType[category] == nil {
            itemsByType[category] = []
        }

        for details in detailsArray {
            itemsByType[category]?.append("\(mainItem) x \(details.quantity)")
            for (extraName, extraQuantity) in details.extras {
                itemsByType[category]?.append("     \(extraName) x \(extraQuantity)")
            }
        }
    }

    return itemsByType
}

func customCategory(fromType type: String) -> String {
    let customCategories: [String: String] = [
        "starter": "Starter",
        "main": "Main",
        "side": "Side",
        "drink": "Drink"
    ]
    
    let lowercasedType = type.lowercased()
    return customCategories[lowercasedType] ?? type
}

func sortItemsByCustomOrder(itemsByType: [String: [String]], customCategoryOrder: [String]) -> [(String, [String])] {
    return itemsByType.sorted { (entry1, entry2) -> Bool in
        let type1 = entry1.key
        let type2 = entry2.key
        let index1 = customCategoryOrder.firstIndex(of: type1) ?? Int.max
        let index2 = customCategoryOrder.firstIndex(of: type2) ?? Int.max
        return index1 < index2
    }
}

func appendCategoriesToReceipt(receipt: inout String, sortedItemsByType: [(String, [String])]) {
    for (type, items) in sortedItemsByType {
        receipt += """
        \nType: \(type)\n
        """
        receipt += items.joined(separator: "\n")
        receipt += "\n"
    }
}

func appendAdditionalInfoToReceipt(receipt: inout String, additionalMessage: String) {
    receipt += """
    -----------------------------
    NOTE: \(additionalMessage.uppercased())
    POWERED BY AEXIR
    KITCHEN RECEIPT
    -----------------------------
    """
}

func trimStringAfterFirstParenthesis(_ input: String) -> String {
    if let range = input.range(of: "(") {
        let trimmedString = input[..<range.lowerBound].trimmingCharacters(in: .whitespaces)
        return String(trimmedString)
    } else {
        return input // If there is no opening parenthesis, return the original string
    }
}
