import Foundation

/// Contract for fetching and decoding a Decodable value from a remote URL.
protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(from url: URL) async throws -> T
}
