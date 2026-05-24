//
//  ProductsSearchView.swift
//  GroceryCheckout
//
//  Created by AR on 2026-05-23.
//  Copyright © 2026. All rights reserved.
//

import SwiftUI

//https://dummyjson.com/products/search?q=phone&limit=10&skip=0

enum FilterType: String, Identifiable, CaseIterable {
    case rating = "Rating"
    case price = "Price"
    case inventory = "Inventory"

    var id: Self { self }
}

@MainActor @Observable
final class ProductsSearchViewModel {

    var searchResults: [Product] = []
    var networkService: DefaultNetworkService = DefaultNetworkService()
    var isLoading: Bool = false
    var isShowError: Bool = false
    var errorStr: String = ""

    var searchQuery: String = ""
    var urlStr: String {
        "https://dummyjson.com/products/search?q=\(searchQuery)&limit=10&skip=0"
    }

    func clearResults() async {
        searchResults = []
    }

    func filterResult(type: FilterType) async {
        switch type {

        case .rating:
            searchResults = searchResults.sorted {
                $0.rating < $1.rating
            }
            break;
        case .price:
            searchResults = searchResults.sorted {
                $0.price < $1.price
            }
            break
        case .inventory:
            searchResults = searchResults.sorted {
                $0.stock < $1.stock
            }
            break;
        }
    }

    func getSearchResults(query: String) async {

        isLoading = true
        defer { isLoading = false }

        do {
            guard let url = URL(string: urlStr) else { throw URLError(.badURL) }
            let productResponse: ProductsResponse = try await networkService.fetch(from: url)
            searchResults = productResponse.products
            errorStr = ""
            isShowError = false
        } catch {
            errorStr = error.localizedDescription
            isShowError = true
        }
    }
}

struct ProductsSearchView: View {

    @State var vm: ProductsSearchViewModel = ProductsSearchViewModel()
    //@State var pickerSelection:FilterType = .rating

    var body: some View {

        NavigationStack {

            VStack {
                HStack(spacing: 10) {
                    TextField("Search", text: $vm.searchQuery)
                        .onChange(of: vm.searchQuery) {
                            print("Search Query = \(vm.searchQuery)")
                        }
                        .backgroundStyle(.white)

                    Button("Rate") {
                        Task {
                            await vm.filterResult(type: .rating)
                        }
                    }
                    Button("Price") {
                        Task {
                            await vm.filterResult(type: .price)
                        }
                    }
                    Button("Stock") {
                        Task {
                            await vm.filterResult(type: .inventory)
                        }
                    }
                }
                .padding()

                if vm.isLoading {
                    ProgressView()
                } else {
                    List(vm.searchResults) { product in
                        NavigationLink(value: product) {
                            ProductsListRowView(product: product)
                        }
                    }
                }
            }
            .navigationDestination(
                for: Product.self,
                destination: { prod in
                    ProductsListDetailView(product: prod)
                }
            )
            .task {
                // initially load 'Phone' search
                await vm.getSearchResults(query: "Phone")
            }
            .task(id: vm.searchQuery) {

                // Trim or normalize if you like
                let query = vm.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)

                // Ignore empty queries if that’s your UX
                guard !query.isEmpty else {
                    await vm.clearResults()
                    return
                }

                do {
                    try await Task.sleep(nanoseconds: 500_000_000)
                    print("Search called for query = \(vm.searchQuery)")
                    await vm.getSearchResults(query: vm.searchQuery)
                } catch {
                    //print("Query Search Cancelled")
                }
            }
            .alert("Error", isPresented: $vm.isShowError) {
                Button("Retry") {
                    Task {
                        await vm.getSearchResults(query: vm.searchQuery)
                    }
                }
            } message: {
                Text("\(vm.errorStr)")
            }
        }
    }
}

#Preview {
    ProductsSearchView()
}
