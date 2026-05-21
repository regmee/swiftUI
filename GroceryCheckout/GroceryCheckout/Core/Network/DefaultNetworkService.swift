import Foundation

/// URLSession-backed implementation of NetworkServiceProtocol.
final class DefaultNetworkService: NetworkServiceProtocol {

    // MARK: - Dependencies

    private let session: URLSession
    private let decoder: JSONDecoder

    // MARK: - Init

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    // MARK: - NetworkServiceProtocol

    func fetch<T: Decodable>(from url: URL) async throws -> T {
        let data: Data
        do {
            let (rawData, _) = try await session.data(from: url)
            data = rawData
        } catch {
            throw NetworkError.networkFailure(error)
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailure(error)
        }
    }
}
