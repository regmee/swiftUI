import Foundation

/// Top-level wrapper returned by the dummyjson.com /products endpoint.
struct ProductsResponse: Decodable, Sendable {
    let products: [Product]
    let total: Int
    let skip: Int
    let limit: Int
}
