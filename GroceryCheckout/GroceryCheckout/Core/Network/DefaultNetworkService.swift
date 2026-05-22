//  DefaultNetworkService.swift
//  GroceryCheckout
//
//  Created by AR on 2026-05-21.
//  Copyright © 2026 AR. All rights reserved.
//

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
            let (rawData, response) = try await session.data(from: url)
            if let http = response as? HTTPURLResponse {
                if (400...499).contains(http.statusCode) { throw NetworkError.clientError(http.statusCode) }
                if (500...599).contains(http.statusCode) { throw NetworkError.serverError(http.statusCode) }
            }
            data = rawData
        } catch let error as NetworkError {
            throw error
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
