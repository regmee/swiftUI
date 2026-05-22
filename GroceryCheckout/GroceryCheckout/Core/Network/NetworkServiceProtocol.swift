//  NetworkServiceProtocol.swift
//  GroceryCheckout
//
//  Created by AR on 2026-05-21.
//  Copyright © 2026 AR. All rights reserved.
//

import Foundation

/// Contract for fetching and decoding a Decodable value from a remote URL.
protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(from url: URL) async throws -> T
}
