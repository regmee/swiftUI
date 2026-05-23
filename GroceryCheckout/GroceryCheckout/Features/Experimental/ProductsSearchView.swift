//
//  ProductsSearchView.swift
//  GroceryCheckout
//
//  Created by AR on 2026-05-23.
//  Copyright © 2026. All rights reserved.
//

import SwiftUI

//https://dummyjson.com/products/search?q=phone&limit=10&skip=0

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

    var body: some View {

        VStack {
            TextField("Search", text: $vm.searchQuery)
                .onChange(of: vm.searchQuery) {
                    print("Search Query = \(vm.searchQuery)")
                }

            Button("Search") {
                Task {
                    await vm.getSearchResults(query: vm.searchQuery)
                }
            }

            if vm.isLoading {
                ProgressView()
            } else {
                List(vm.searchResults) { product in
                    Text(product.title)
                }
            }
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

#Preview {
    ProductsSearchView()
}
