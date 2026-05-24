//
//  ContentView.swift
//  SwiftUIwithKMP
//
//  Created by AR on 2026-05-24.
//  Copyright © 2026. All rights reserved.
//

import SwiftUI
import shared   // KMP XCFramework module

// ─── Swift / KMP Interop Notes ────────────────────────────────────────────────
//
// Kotlin class `Product`  (module `shared`)
//   → ObjC class `Product`  → Swift type `Product`
//
// suspend fun fetchProducts(): List<Product>  +  @Throws(Exception::class)
//   → Swift: func fetchProducts() async throws -> [Product]
//
// Kotlin `Int`     property → Swift `Int32`
// Kotlin `Double`  property → Swift `Double`
// Kotlin `String`  property → Swift `String`
// Kotlin `String?` property → Swift `String?`
//
// The `as! [Product]` cast below is safe: KMP guarantees the element
// type from the ObjC NSArray bridge. Swap for `.compactMap { $0 as? Product }`
// if a compiler warning appears under strict Swift 6 concurrency checking.
//
// ─────────────────────────────────────────────────────────────────────────────

// MARK: - ViewModel

@Observable
final class ProductsViewModel {
    var products: [Product] = []
    var isLoading = false
    var errorMessage: String? = nil

    private let repository = ProductRepository()

    func loadProducts() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                // fetchProducts() bridges from Kotlin `suspend fun` via ObjC async
                products = try await repository.fetchProducts() 
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

// MARK: - View

struct ContentView: View {
    @State private var viewModel = ProductsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading products…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.red)
                        Text("Failed to load")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Retry") {
                            viewModel.loadProducts()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                } else if viewModel.products.isEmpty {
                    ContentUnavailableView(
                        "No Products",
                        systemImage: "cart.badge.questionmark",
                        description: Text("Products will appear here once loaded.")
                    )

                } else {
                    List(viewModel.products, id: \.id) { product in
                        ProductRowView(product: product)
                    }
                    .refreshable {
                        viewModel.loadProducts()
                    }
                }
            }
            .navigationTitle("Products (via KMP)")
        }
        .task {
            viewModel.loadProducts()
        }
    }
}

// MARK: - Product Row

private struct ProductRowView: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(product.title)
                .font(.headline)
            Text(product.category)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Text(String(format: "$%.2f", product.price))
                    .font(.subheadline)
                    .foregroundStyle(.green)
                Spacer()
                Label(
                    String(format: "%.1f", product.rating),
                    systemImage: "star.fill"
                )
                .font(.caption)
                .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
