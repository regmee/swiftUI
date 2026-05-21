import Foundation
import Observation

/// Drives the Products list screen: loads products from the network and tracks selection.
@MainActor
@Observable
final class ProductsListViewModel {

    // MARK: - State

    private(set) var products: [Product] = []
    private(set) var selectedProduct: Product?
    private(set) var errorMessage: String?
    private(set) var isLoading: Bool = false

    // MARK: - Dependencies

    private let networkService: any NetworkServiceProtocol

    // MARK: - Private

    private let productsURL = URL(string: "https://dummyjson.com/products?limit=20")!

    // MARK: - Init

    init(networkService: any NetworkServiceProtocol = DefaultNetworkService()) {
        self.networkService = networkService
    }

    // MARK: - Intents

    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let response: ProductsResponse = try await networkService.fetch(from: productsURL)
            products = response.products
        } catch let error as NetworkError {
            switch error {
            case .networkFailure:
                errorMessage = "Could not connect to the server. Please check your connection."
            case .decodingFailure:
                errorMessage = "Received unexpected data from the server. Please try again later."
            }
        } catch {
            errorMessage = "An unexpected error occurred. Please try again."
        }
    }

    func selectProduct(_ product: Product) {
        selectedProduct = product
    }
}
