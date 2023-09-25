//
//  ReceiptMakerApp.swift
//  ReceiptMaker
//
//  Created by Ahmed Henna on 9/25/23.
//

import SwiftUI
import Firebase


@main
struct ReceiptMakerApp: App {
    
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
