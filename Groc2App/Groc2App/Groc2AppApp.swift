//
//  Groc2AppApp.swift
//  Groc2App
//
//  Created by AR on 2026-05-25.
//  Copyright © 2026. All rights reserved.
//


import SwiftUI

@main
struct Groc2AppApp: App {

    @State var favManager: FavoriteManager = FavoriteManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(favManager)
        }
    }
}
