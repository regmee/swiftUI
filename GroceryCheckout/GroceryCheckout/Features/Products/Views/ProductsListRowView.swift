//  ProductsListRowView.swift
//  GroceryCheckout
//
//  Created by AR on 2026-05-21.
//  Copyright © 2026 AR. All rights reserved.
//

import SwiftUI

struct ProductsListRowView: View {

    let product: Product

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: product.thumbnail)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 60, height: 60)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipped()
                case .failure:
                    Image(systemName: "photo")
                        .frame(width: 60, height: 60)
                @unknown default:
                    EmptyView()
                }
            }
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(product.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack(spacing: 12) {
                    Label(product.category, systemImage: "tag")
                    Label(String(format: "%.1f", product.rating), systemImage: "star.fill")
                    Label("\(product.stock)", systemImage: "shippingbox")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ProductsListRowView(product: Product(
        id: 1, title: "Essence Mascara Lash Princess", description: "The Essence Mascara Lash Princess is a popular mascara known for its volumizing and lengthening effects.",
        category: "beauty", price: 9.99, rating: 4.94,
        stock: 5, brand: "Essence", thumbnail: "https://cdn.dummyjson.com/products/images/beauty/Essence%20Mascara%20Lash%20Princess/thumbnail.png"
    ))
    .padding()
}
