//  CounterViewModel.swift
//  GroceryCheckout
//
//  Created by AR on 2026-05-21.
//  Copyright © 2026 AR. All rights reserved.
//

import Foundation
import Observation

/// Manages the counter state and exposes intents for the Counter screen.
@MainActor
@Observable
final class CounterViewModel {

    // MARK: - State

    private(set) var count: Int = 0

    var canDecrement: Bool { count > 0 }

    // MARK: - Intents

    func increment() {
        count += 1
    }

    func decrement() {
        guard canDecrement else { return }
        count -= 1
    }

    func reset() {
        count = 0
    }
}
