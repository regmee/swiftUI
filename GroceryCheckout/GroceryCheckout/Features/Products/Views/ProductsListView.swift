//  ProductsListView.swift
//  GroceryCheckout
//
//  Created by AR on 2026-05-21.
//  Copyright © 2026 AR. All rights reserved.
//

import SwiftUI

struct ProductsListView: View {

    @State private var viewModel: ProductsListViewModel

    init(viewModel: ProductsListViewModel = ProductsListViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading products…")
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Something went wrong",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else {
                    List {
                        ForEach(viewModel.products) { product in
                            NavigationLink(value: product) {
                                ProductsListRowView(product: product)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Products")
            .navigationDestination(for: Product.self) { product in
                ProductsListDetailView(product: product)
                    .onAppear { viewModel.selectProduct(product) }
            }
            .task { await viewModel.loadProducts() }
        }
    }
}

#Preview {
    ProductsListView()
}
