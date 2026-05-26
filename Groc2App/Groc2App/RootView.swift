//
//  RootView.swift
//  Groc2App
//
//  Created by AR on 2026-05-25.
//  Copyright © 2026. All rights reserved.
//

import SwiftUI
import Observation

/*

 {
     products: [
         {
             id: 1,
             title: "Essence Mascara Lash Princess",
             description: "The Essence Mascara Lash Princess is a popular mascara known for its volumizing and lengthening effects. Achieve dramatic lashes with this long-lasting and cruelty-free formula.",
             category: "beauty",
             price: 9.99,
             discountPercentage: 10.48,
             rating: 2.56,
             stock: 99,
             tags: [
                 "beauty",
                 "mascara"
             ],
             brand: "Essence",
             sku: "BEA-ESS-ESS-001",
             weight: 4,
             dimensions: {
                 width: 15.14,
                 height: 13.08,
                 depth: 22.99
             },

 */

actor FavoriteStore {

    func getFav(id: Int) -> Bool {
        UserDefaults.standard.bool(forKey: "\(id)")
    }

    func setFav(id: Int, state: Bool) {
        UserDefaults.standard.set(state, forKey: "\(id)")
    }
}

@Observable
final class FavoriteManager {

    private let favStore: FavoriteStore = FavoriteStore()

    func getFav(id: Int) async -> Bool {
        await favStore.getFav(id: id)
    }

    func setFav(id: Int, state: Bool) async {
        await favStore.setFav(id: id, state: state)
    }
}

//struct FavoriteStore {
//    func getFav(id: Int) -> Bool {
//        UserDefaults.standard.bool(forKey: "\(id)")
//    }
//
//    func setFav(id: Int, state: Bool) {
//        UserDefaults.standard.set(state, forKey: "\(id)")
//    }
//}
//
//@MainActor
//@Observable
//final class FavoriteManager {
//    private let favStore = FavoriteStore()
//
//    func getFav(id: Int) -> Bool {
//        favStore.getFav(id: id)
//    }
//
//    func setFav(id: Int, state: Bool) {
//        favStore.setFav(id: id, state: state)
//    }
//}

struct ProductRoot: Decodable {
    let products: [Product]
}

struct Product: Identifiable, Decodable, Hashable {
    let id: Int
    let title: String
    let description: String
    let rating: Double
    let price: Double
    let stock: Int
}

protocol NetworkServiceProtocol {
    func getDataFromAPI(urlStr: String) async throws -> [Product]
}

struct NetworkService: NetworkServiceProtocol {

    let urlSession = URLSession.shared

    func getDataFromAPI(urlStr: String) async throws -> [Product] {

        guard let url = URL(string: urlStr) else { throw URLError(.badURL) }

        let (data, response) = try await URLSession.shared.data(from: url)  // also certificate pinning

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        switch httpResponse.statusCode {
            case 100...199:  // Informative
                throw URLError(.badServerResponse)
            case 200...299:  // success
                do {
                    let decodeResult = try JSONDecoder().decode(ProductRoot.self, from: data)
                    return decodeResult.products
                } catch {
                    throw error
                }
            case 300...399:  // redirections ?
                throw URLError(.badServerResponse)
            case 400...499:  // client error
                throw URLError(.badServerResponse)
            case 500...599:  // server error
                throw URLError(.badServerResponse)
            default:
                throw URLError(.unknown)
        }
    }
}

@MainActor @Observable
final class HomeViewModel {

    let productsEndpoint: String = "https://dummyjson.com/products?limit=20&skip=0"
    let productSearchEndpoint: String = "https://dummyjson.com/products/search?q="

    var queryStr: String = ""

    var products: [Product] = []
    var isLoading: Bool = false

    var isShowError: Bool = false
    var errorMsg: String = ""

    let netwokService: NetworkServiceProtocol
    init(netwokService: NetworkServiceProtocol) {
        self.netwokService = netwokService
    }

    func searchProducts(query: String) async {

        isLoading = true
        defer {
            isLoading = false
        }

        do {
            products = try await self.netwokService.getDataFromAPI(
                urlStr: productSearchEndpoint + self.queryStr)
            errorMsg = ""
            isShowError = false
        } catch {
            errorMsg = error.localizedDescription
            isShowError = true
        }
    }

    func sortByQty() {
        products = products.sorted {
            $0.stock < $1.stock
        }
    }

    func getProducts() async {

        isLoading = true
        defer {
            isLoading = false
        }

        do {
            products = try await self.netwokService.getDataFromAPI(urlStr: productsEndpoint)
            errorMsg = ""
            isShowError = false
        } catch {
            errorMsg = error.localizedDescription
            isShowError = true
        }
    }
}

struct HomeView: View {

    @State var vm: HomeViewModel = HomeViewModel(netwokService: NetworkService())

    var body: some View {

        NavigationStack {
            VStack {
                HStack {
                    TextField("Search", text: $vm.queryStr)
                    Spacer()
                    Button("Sort by Qty") {
                        vm.sortByQty()
                    }
                }

                List(vm.products) { prod in
                    NavigationLink(value: prod) {
                        ProductRowView(prod: prod)
                    }
                }
            }
            .navigationDestination(for: Product.self, destination: { prod in
                ProductDetailView(prod: prod, favState: false)
            })
            .alert(
                "Error", isPresented: $vm.isShowError,
                actions: {
                    Button("Retry") {
                        Task {
                            if !vm.isLoading {
                                await vm.getProducts()
                            }
                        }
                    }
                },
                message: {
                    Text("\(vm.errorMsg)")
                }
            )
            .task(
                id: vm.queryStr,
                {
                    // handle debouncing
                    do {
                        try await Task.sleep(nanoseconds: 500_000_000)
                        print("sending search query = \(vm.queryStr)")
                        await vm.searchProducts(query: vm.queryStr)
                    } catch {
                        print("Error = \(error.localizedDescription)")
                    }
                }
            )
            .task {
                await vm.getProducts()
            }
            .background(.clear)
        }
    }
}

struct RootView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "heart") }
            CheckoutView()
                .tabItem { Label("Checkout", systemImage: "gear") }
        }
    }
}

#Preview {
    RootView()
}
