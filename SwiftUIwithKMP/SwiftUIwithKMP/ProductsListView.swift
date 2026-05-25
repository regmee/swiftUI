//
//  ProductsListView.swift
//  SwiftUIwithKMP
//
//  Created by AR on 2026-05-24.
//  Copyright © 2026. All rights reserved.
//

import SwiftUI
import shared  // KMP XCFramework module

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
final class ProductsListViewModel {
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

// MARK: - Products List View

struct ProductsListView: View {
    @State private var viewModel = ProductsListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .controlSize(.large)
                        Text("Loading products…")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(.red)
                        Text("Failed to Load")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Button("Try Again") {
                            viewModel.loadProducts()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
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
                        let item = ProductItem(product)
                        NavigationLink(value: item) {
                            ProductRowView(product: item.product)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        viewModel.loadProducts()
                    }
                }
            }
            .navigationDestination(for: ProductItem.self) { item in
                ProductsDetailView(product: item.product, isFav: true)
            }
            .navigationTitle("Products")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            viewModel.loadProducts()
        }
    }
}

// KMP-exposed type (from shared Kotlin code)
typealias KmpProduct = shared.Product

struct ProductItem: Hashable {
    let id: Int32
    let product: KmpProduct

    init(_ product: KmpProduct) {
        self.id = product.id           // or whatever stable ID KMP exposes
        self.product = product
    }
}

// MARK: - Product Row

private struct ProductRowView: View, Hashable {
    let product: Product

    var body: some View {
        HStack(spacing: 14) {
            AsyncImage(url: URL(string: product.thumbnail)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                default:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(width: 70, height: 70)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(product.category.capitalized)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.blue.opacity(0.85))
                    .clipShape(Capsule())

                HStack(spacing: 4) {
                    Text(String(format: "$%.2f", product.price))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)

                    Spacer()

                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Text(String(format: "%.1f", product.rating))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Cart View

struct CartView: View {

    @Environment(CartManagerViewModel.self) private var cartManager
    @State var cartItems: [Order] = []

    func getTotalPrice() -> Double {
        cartItems.reduce(0.0) { partialResult, order in
            partialResult + order.price * Double(order.qty)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if cartItems.isEmpty {
                    ContentUnavailableView(
                        "Cart is Empty",
                        systemImage: "cart",
                        description: Text("Add products from the catalogue to get started.")
                    )
                } else {
                    List {
                        Section {
                            ForEach(cartItems) { order in
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(order.title)
                                            .font(.headline)
                                            .lineLimit(2)
                                        Text("Qty: \(order.qty)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(String(format: "$%.2f", order.price * Double(order.qty)))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.green)
                                }
                                .padding(.vertical, 4)
                            }
                        }

                        Section {
                            HStack {
                                Text("Total")
                                    .font(.headline)
                                Spacer()
                                Text(String(format: "$%.2f", getTotalPrice()))
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Your Cart")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            cartItems = await cartManager.getCart()
        }
    }
}

// MARK: - Product Detail View

struct ProductsDetailView: View {

    @Environment(FavoriteStoreViewModel.self) private var favStore
    @Environment(CartManagerViewModel.self) private var cartManager

    let product: Product
    @State var isFav: Bool
    @State var isAddedToCart: Bool = false
    @State var loadCartView: Bool = false

    func toggleFavState() {
        Task {
            isFav.toggle()
            await favStore.setFavoriteState(id: product.id, state: isFav)
        }
    }

    func addProductToCart() {
        Task {
            let order: Order = Order(
                id: product.id,
                qty: 1,
                title: product.title,
                price: product.price
            )
            await cartManager.saveCart(orders: [order])
            isAddedToCart = true
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // ── Hero image ───────────────────────────────────────────────
                AsyncImage(url: URL(string: product.thumbnail)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(systemName: "photo")
                            .font(.system(size: 64))
                            .foregroundStyle(.tertiary)
                            .frame(maxWidth: .infinity)
                    default:
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .background(Color(.systemGray6))

                VStack(alignment: .leading, spacing: 16) {

                    // ── Category + title ─────────────────────────────────────
                    VStack(alignment: .leading, spacing: 8) {
                        Text(product.category.uppercased())
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.blue)
                            .clipShape(Capsule())

                        Text(product.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // ── Price + rating ───────────────────────────────────────
                    HStack(alignment: .firstTextBaseline, spacing: 16) {
                        Text(String(format: "$%.2f", product.price))
                            .font(.title)
                            .fontWeight(.heavy)
                            .foregroundStyle(.green)

                        Spacer()

                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.orange)
                            Text(String(format: "%.1f", product.rating))
                                .fontWeight(.semibold)
                            Text("· \(product.stock) in stock")
                                .foregroundStyle(.secondary)
                        }
                        .font(.subheadline)
                    }

                    Divider()

                    // ── Description ──────────────────────────────────────────
                    Text(product.description())
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Divider()

                    // ── Favourite badge ──────────────────────────────────────
                    HStack(spacing: 8) {
                        Image(systemName: isFav ? "heart.fill" : "heart")
                            .foregroundStyle(isFav ? .red : .secondary)
                        Text(isFav ? "Saved to Favourites" : "Not in Favourites")
                            .font(.subheadline)
                            .foregroundStyle(isFav ? .primary : .secondary)
                    }

                    // ── Action buttons ───────────────────────────────────────
                    VStack(spacing: 10) {
                        Button {
                            addProductToCart()
                        } label: {
                            Label(
                                isAddedToCart ? "Added to Cart" : "Add to Cart",
                                systemImage: isAddedToCart ? "cart.badge.checkmark" : "cart.badge.plus"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(isAddedToCart)

                        HStack(spacing: 10) {
                            Button {
                                toggleFavState()
                            } label: {
                                Label(
                                    isFav ? "Unfavourite" : "Favourite",
                                    systemImage: isFav ? "heart.fill" : "heart"
                                )
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(isFav ? .red : .gray)
                            .controlSize(.large)

                            Button {
                                loadCartView = true
                            } label: {
                                Label("View Cart", systemImage: "cart")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                        }
                    }
                }
                .padding(20)
            }
        }
        .sheet(isPresented: $loadCartView) {
            CartView()
        }
        .task {
            self.isFav = await favStore.getFavoriteState(id: product.id)
        }
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .top)
    }
}

// MARK: - Data

struct Order: Identifiable, Codable {
    let id: Int32
    let qty: Int
    let title: String
    let price: Double
}

actor CartManager {
    func saveCart(orders: [Order]) {
        let encoder: JSONEncoder = JSONEncoder()
        do {
            let encodedData = try encoder.encode(orders)
            UserDefaults.standard.set(encodedData, forKey: "orders")
        } catch {
            print("Encode error \(error.localizedDescription)")
        }
    }

    func getCart() -> [Order] {
        let decoder: JSONDecoder = JSONDecoder()
        do {
            let data: Data = UserDefaults.standard.data(forKey: "orders") ?? Data()
            return try decoder.decode([Order].self, from: data)
        } catch {
            print("Decode error \(error.localizedDescription)")
        }
        return []
    }
}

@Observable
final class CartManagerViewModel {
    let cartManager: CartManager

    init(cartManager: CartManager) {
        self.cartManager = cartManager
    }

    func saveCart(orders: [Order]) async {
        var cartItems: [Order] = await getCart()
        cartItems.append(contentsOf: orders)
        await cartManager.saveCart(orders: cartItems)
    }

    func getCart() async -> [Order] {
        await cartManager.getCart()
    }
}

@Observable
final class FavoriteStoreViewModel {

    let favStore: FavoriteStore

    init(favStore: FavoriteStore) {
        self.favStore = favStore
    }

    func getFavoriteState(id: Int32) async -> Bool {
        await favStore.getFavoriteState(id: id)
    }

    func setFavoriteState(id: Int32, state: Bool) async {
        await favStore.setFavoriteState(id: id, state: state)
    }
}

actor FavoriteStore {
    func getFavoriteState(id: Int32) -> Bool {
        UserDefaults.standard.bool(forKey: "\(id)")
    }

    func setFavoriteState(id: Int32, state: Bool) {
        UserDefaults.standard.set(state, forKey: "\(id)")
    }
}

// MARK: - Preview

#Preview {
    ProductsListView()
        .environment(FavoriteStoreViewModel(favStore: FavoriteStore()))
        .environment(CartManagerViewModel(cartManager: CartManager()))

//    ProductsDetailView(
//        product: Product(
//            id: 1,
//            title: "Hello Product",
//            description: "Hello Desc",
//            category: "Tech",
//            price: 12.0,
//            rating: 3.4,
//            stock: 2,
//            brand: nil,
//            thumbnail: "https://somerandomimage.com/images/12123"
//        ),
//        isFav: false
//    )
}
