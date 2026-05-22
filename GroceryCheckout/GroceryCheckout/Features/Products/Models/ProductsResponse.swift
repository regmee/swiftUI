//  ProductsResponse.swift
//  GroceryCheckout
//
//  Created by AR on 2026-05-21.
//  Copyright © 2026 AR. All rights reserved.
//

import Foundation

/// Top-level wrapper returned by the dummyjson.com /products endpoint.
struct ProductsResponse: Decodable, Sendable {
    let products: [Product]
    let total: Int
    let skip: Int
    let limit: Int
}
