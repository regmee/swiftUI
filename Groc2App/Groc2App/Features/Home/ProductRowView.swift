//
//  ProductRowView.swift
//  Groc2App
//
//  Created by AR on 2026-05-25.
//  Copyright © 2026. All rights reserved.
//

import SwiftUI

struct ProductRowView: View {

    let prod: Product

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(prod.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .lineLimit(2)
                Text(prod.description)
                    .lineLimit(3)
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
    }
}
