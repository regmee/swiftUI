//
//  GroceryCheckoutApp.swift
//  GroceryCheckout
//
//  Created by AR on 2026-05-20.
//  Copyright © 2026. All rights reserved.
//


import SwiftUI

@main
struct GroceryCheckoutApp: App {
    @State private var favoriteStore:FavoriteStoreViewModel = FavoriteStoreViewModel(store: FavoriteStore())

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(favoriteStore)
        }
    }
}
