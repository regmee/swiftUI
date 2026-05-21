import Foundation

/// Errors the network layer surfaces to callers.
enum NetworkError: Error {
    case networkFailure(Error)
    case decodingFailure(Error)
}
