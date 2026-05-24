//  ProductsListDetailView.swift
//  GroceryCheckout
//
//  Created by AR on 2026-05-21.
//  Copyright © 2026 AR. All rights reserved.
//

import SwiftUI
import Observation

actor FavoriteStore {
    func getFavState(prod: Product) -> Bool {
        UserDefaults.standard.bool(forKey: "\(prod.id)")
    }

    func setFavState(prod: Product, state: Bool) {
        UserDefaults.standard.set(state, forKey: "\(prod.id)")
        print("Product Id = \(prod.id) set to \(state)")
    }
}

@Observable
final class FavoriteStoreViewModel {

    private let store: FavoriteStore

    init(store: FavoriteStore) {
        self.store = store
    }

    func getFavState(prod: Product) async -> Bool {
        await self.store.getFavState(prod: prod)
    }

    func setFavState(prod: Product, state: Bool) async {
        await self.store.setFavState(prod: prod, state: state)
    }
}

struct ProductsListDetailView: View {

    let product: Product
    @State var isProductFav: Bool = false
    @Environment(FavoriteStoreViewModel.self) private var favoriteStore

    func toggleFavorite() {
        Task {
            let newValue = !isProductFav
            // Update UI state immediately
            isProductFav = newValue
            // Persist to store
            await favoriteStore.setFavState(prod: product, state: newValue)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ZStack {

                    AsyncImage(url: URL(string: product.thumbnail)) { phase in
                        switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity, minHeight: 240)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, minHeight: 240)
                                    .foregroundStyle(.secondary)
                            @unknown default:
                                EmptyView()
                        }
                    }
                    .cornerRadius(12)

                    Button {
                        self.toggleFavorite()
                    } label: {
                        Image(
                            systemName: isProductFav ? "heart.fill" : "heart"
                        )
                        .frame(width: 200, height: 200)
                        .foregroundColor(isProductFav ? .red : .blue)
                        .font(.title2)
                        .padding(8)
                        .background(Color(.systemBackground).opacity(0.8))
                        .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(product.title)
                        .font(.title2)
                        .bold()

                    Text(product.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Divider()

                VStack(spacing: 0) {
                    DetailRow(label: "Category", value: product.category)
                    DetailRow(label: "Price", value: String(format: "$%.2f", product.price))
                    DetailRow(label: "Rating", value: String(format: "%.2f / 5.00", product.rating))
                    DetailRow(label: "Stock", value: "\(product.stock) units")
                    if let brand = product.brand {
                        DetailRow(label: "Brand", value: brand)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(product.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Initialize favorite state when the view appears
            isProductFav = await favoriteStore.getFavState(prod: product)
        }
    }
}

// MARK: - Supporting Views

private struct DetailRow: View {

    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
        .padding(.vertical, 10)
        Divider()
    }
}

#Preview {
    NavigationStack {
        ProductsListDetailView(
            product: Product(
                id: 1, title: "Essence Mascara Lash Princess",
                description:
                    "The Essence Mascara Lash Princess is a popular mascara known for its volumizing and lengthening effects.",
                category: "beauty", price: 9.99, rating: 4.94,
                stock: 5, brand: "Essence",
                thumbnail:
                    "https://cdn.dummyjson.com/products/images/beauty/Essence%20Mascara%20Lash%20Princess/thumbnail.png"
            ))
    }
}
