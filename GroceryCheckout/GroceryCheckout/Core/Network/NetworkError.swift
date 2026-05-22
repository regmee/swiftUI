import Foundation

/// Errors the network layer surfaces to callers.
enum NetworkError: Error {
    case networkFailure(Error)   // URLSession-level failure (no connectivity, timeout, DNS)
    case clientError(Int)        // 4xx — bad request, not found, unauthorized, etc.
    case serverError(Int)        // 5xx — internal server error, unavailable, etc.
    case decodingFailure(Error)  // JSON shape doesn't match the expected model
}
