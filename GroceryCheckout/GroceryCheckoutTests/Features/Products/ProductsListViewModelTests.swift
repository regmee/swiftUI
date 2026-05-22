//  ProductsListViewModelTests.swift
//  GroceryCheckout
//
//  Created by AR on 2026-05-21.
//  Copyright © 2026 AR. All rights reserved.
//

import Testing
import Foundation
@testable import GroceryCheckout

@MainActor
struct ProductsListViewModelTests {

    // MARK: - loadProducts

    @Test
    func loadProducts_onSuccess_populatesProducts() async {
        // Arrange
        let product = Product(
            id: 1, title: "Essence Mascara", description: "A great mascara.",
            category: "beauty", price: 9.99, rating: 4.94,
            stock: 5, brand: "Essence", thumbnail: "https://cdn.example.com/img.jpg"
        )
        let mock = MockNetworkService()
        mock.result = .success(ProductsResponse(products: [product], total: 1, skip: 0, limit: 20))
        let sut = ProductsListViewModel(networkService: mock)

        // Act
        await sut.loadProducts()

        // Assert
        #expect(sut.products.count == 1)
        #expect(sut.products.first?.id == 1)
        #expect(sut.errorMessage == nil)
    }

    @Test
    func loadProducts_onNetworkError_setsUserFacingErrorMessage() async {
        // Arrange
        let mock = MockNetworkService()
        mock.result = .failure(NetworkError.networkFailure(URLError(.notConnectedToInternet)))
        let sut = ProductsListViewModel(networkService: mock)

        // Act
        await sut.loadProducts()

        // Assert
        #expect(sut.products.isEmpty)
        #expect(sut.errorMessage != nil)
    }

    @Test
    func loadProducts_onDecodingError_setsUserFacingErrorMessage() async {
        // Arrange
        let mock = MockNetworkService()
        mock.result = .failure(NetworkError.decodingFailure(
            DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "bad json"))
        ))
        let sut = ProductsListViewModel(networkService: mock)

        // Act
        await sut.loadProducts()

        // Assert
        #expect(sut.products.isEmpty)
        #expect(sut.errorMessage != nil)
    }

    @Test
    func parse_withMalformedJSON_throwsDecodingError() {
        // Arrange
        let badData = Data("not json".utf8)

        // Assert
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(ProductsResponse.self, from: badData)
        }
    }

    @Test
    func selectProduct_setsSelectedProduct() {
        // Arrange
        let product = Product(
            id: 42, title: "Test Product", description: "desc",
            category: "test", price: 1.0, rating: 3.0,
            stock: 10, brand: nil, thumbnail: ""
        )
        let sut = ProductsListViewModel(networkService: MockNetworkService())

        // Act
        sut.selectProduct(product)

        // Assert
        #expect(sut.selectedProduct?.id == 42)
    }
}

// MARK: - Fakes

private final class MockNetworkService: NetworkServiceProtocol, @unchecked Sendable {
    // @unchecked Sendable: mutated only from @MainActor test methods — no true concurrency.
    var result: Result<ProductsResponse, Error> = .success(
        ProductsResponse(products: [], total: 0, skip: 0, limit: 0)
    )

    func fetch<T: Decodable>(from url: URL) async throws -> T {
        switch result {
        case .success(let response):
            // Force-cast is intentional: T is always ProductsResponse in these tests.
            return response as! T
        case .failure(let error):
            throw error
        }
    }
}
