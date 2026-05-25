//
//  SwiftUIwithKMPApp.swift
//  SwiftUIwithKMP
//
//  Created by AR on 2026-05-24.
//  Copyright © 2026. All rights reserved.
//


import SwiftUI

@main
struct SwiftUIwithKMPApp: App {

    @State var favoriteVM: FavoriteStoreViewModel = FavoriteStoreViewModel( favStore: FavoriteStore())
    @State var cartManagerViewModel: CartManagerViewModel = CartManagerViewModel(cartManager: CartManager())

    var body: some Scene {
        WindowGroup {
            ProductsListView()
                .environment(favoriteVM)
                .environment(cartManagerViewModel)
        }
    }
}
