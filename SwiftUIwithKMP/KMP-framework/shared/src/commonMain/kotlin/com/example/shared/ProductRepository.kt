package com.example.shared

import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.json.Json

private const val PRODUCTS_URL = "https://dummyjson.com/products"

/**
 * Fetches products from the DummyJSON API.
 *
 * Two constructors:
 *   - `ProductRepository()` — used by Swift (no-arg, picks the Darwin HTTP engine on iOS).
 *     Kotlin default parameter values are NOT exported to ObjC/Swift, so an explicit
 *     no-arg constructor is required for Swift to call `ProductRepository()`.
 *   - `ProductRepository(httpClient)` — used by KMP unit tests to inject a MockEngine.
 *
 * Swift exposure:
 *   `@Throws(Exception::class)` makes the suspend function bridge to Swift as
 *   `func fetchProducts() async throws -> [Product]`.
 *   Without @Throws, Kotlin exceptions bypass Swift's error handling and crash the app.
 */
class ProductRepository(private val httpClient: HttpClient) {

    /** No-arg constructor for Swift. Creates the default Darwin-backed HTTP client. */
    constructor() : this(
        HttpClient {
            install(ContentNegotiation) {
                json(Json {
                    ignoreUnknownKeys = true  // API returns extra fields not in our model
                })
            }
        }
    )

    @Throws(Exception::class)
    suspend fun fetchProducts(): List<Product> =
        httpClient
            .get(PRODUCTS_URL)
            .body<ProductsResponse>()
            .products
}
