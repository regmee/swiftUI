import Foundation

/// A single product from the dummyjson.com API.
struct Product: Identifiable, Decodable, Hashable, Sendable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Double
    let rating: Double
    let stock: Int
    let brand: String?
    let thumbnail: String
}
