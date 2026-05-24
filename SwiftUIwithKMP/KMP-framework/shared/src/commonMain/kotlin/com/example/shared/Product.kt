package com.example.shared

import kotlinx.serialization.Serializable

/**
 * Represents a single product from the DummyJSON API.
 *
 * Swift interop:
 *   Kotlin class `Product` in module `shared` → ObjC class `SharedProduct` → Swift type `SharedProduct`
 *   Kotlin `Int`    → Swift `Int32`
 *   Kotlin `Double` → Swift `Double`
 *   Kotlin `String` → Swift `String`
 *   Kotlin `String?`→ Swift `String?`
 */
@Serializable
data class Product(
    val id: Int,
    val title: String,
    val description: String,
    val category: String,
    val price: Double,
    val rating: Double,
    val stock: Int,
    val brand: String? = null,   // Nullable: absent for some categories (e.g. groceries)
    val thumbnail: String
)

/**
 * Top-level wrapper returned by https://dummyjson.com/products.
 * Only `products` is mapped; other pagination fields (total, skip, limit)
 * are ignored via `ignoreUnknownKeys = true` in the JSON decoder.
 */
@Serializable
data class ProductsResponse(
    val products: List<Product>
)
