//
//  ContentView.swift
//  ReceiptMaker
//
//  Created by Ahmed Henna on 9/25/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var menuItemStore = MenuItemsStore()

    var body: some View {
        VStack {
            // Example usage:
            let orderName = "Order 123"
            let tabdel = "Dine-in"
            let additionalMessage = "Please prepare the order quickly."
            let items = [
                "Chocolate Donut: (3.0), Extras: Chocolate Sauce (0.52), Extras: Chocolate Sauce (0.52), Extras: Chocolate Sauce (0.52)",
                "Soda Can: (1.0)",
                "Chocolate Donut: (3.0), Extras: Chocolate Sauce (0.52)",
                "Soda Can: (1.0), Extras: Straw(1.0)",
            ]

            //here is where youll replace all the paramters with the ones you get from firestore
            let receipt = generateReceiptForKitchen(orderName: orderName, orderPrice: 10.0, tabdel: tabdel, additionalMessage: additionalMessage, arrivalTime: "", refundAmount: 0.0, tip: 0.0, items: items, sizes: [], mealDeals: [], menuItemStore: menuItemStore)

            Text(receipt)
        }
        .padding()
        .onAppear {
            menuItemStore.fetchMenuItems()
        }
    }
}


