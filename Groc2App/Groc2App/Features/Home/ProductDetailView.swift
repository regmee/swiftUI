//
//  ProductDetailView.swift
//  Groc2App
//
//  Created by AR on 2026-05-25.
//  Copyright © 2026. All rights reserved.
//

import SwiftUI

struct ProductDetailView: View {

    @Environment(FavoriteManager.self) private var favManager
    let prod: Product
    @State var favState: Bool

    func getProdFavState() {
        Task {
            favState = await favManager.getFav(id: prod.id)
        }
    }

    var body: some View {

        VStack {

            HStack {
                VStack(alignment: .leading) {
                    Text(prod.title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .lineLimit(2)
                    Text(prod.description)
                        .font(.footnote)
                }
                Spacer()

                VStack(alignment: .trailing) {
                    Text(String(format: "%.2f", prod.price))
                        .font(.subheadline)
                    Text("\(prod.stock)")
                        .font(.subheadline)
                }
            }
            .padding()

            HStack {

                Button("", systemImage: favState ? "heart.fill" : "heart") {
                    favState.toggle()
                    Task {
                      await favManager.setFav(id: prod.id, state: favState)
                    }
                }

                Spacer()

                Button("Add to Cart") {

                }
            }
            .padding()

            HStack {
                Spacer()
                Button("View Cart") {

                }
            }
            .padding()
        }
        .task {
            getProdFavState()
        }
    }
}

//#Preview {
//    ProductDetailView(
//        prod: Product(
//            id: 3, title: "Hello Title",
//            description:
//                "Hello Desc jsajflk asjflkjas  asfdjslajk fja fsdajl as lk \n adlkfj asdfjlkas  asjldkj fas jksalj as flkajs a sfdj lkasj asfdj lkjasl fajsf ;ja; sfj; j;askljf;ld",
//            rating: 3.4, price: 5.99, stock: 34)
//    )
//}
