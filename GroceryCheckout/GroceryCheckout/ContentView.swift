//
//  ContentView.swift
//  GroceryCheckout
//
//  Created by AR on 2026-05-20.
//  Copyright © 2026. All rights reserved.
//


import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CounterView()
                .tabItem { Label("Counter", systemImage: "number.circle") }
            ProductsListView()
                .tabItem { Label("Products", systemImage: "cart") }
        }
    }
}

#Preview {
    ContentView()
}
