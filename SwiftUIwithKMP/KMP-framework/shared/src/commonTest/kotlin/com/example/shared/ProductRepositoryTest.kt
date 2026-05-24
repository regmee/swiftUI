package com.example.shared

import io.ktor.client.*
import io.ktor.client.engine.mock.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.coroutines.test.runTest
import kotlinx.serialization.json.Json
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

// ─── Fixtures ────────────────────────────────────────────────────────────────

private val MOCK_PRODUCT_JSON = """
{
  "products": [{
    "id": 1,
    "title": "Essence Mascara",
    "description": "A highly pigmented mascara.",
    "category": "beauty",
    "price": 9.99,
    "rating": 4.94,
    "stock": 5,
    "brand": "Essence",
    "thumbnail": "https://cdn.dummyjson.com/thumb.png"
  }]
}
""".trimIndent()

private val NO_BRAND_JSON = """
{
  "products": [{
    "id": 2,
    "title": "Grocery Item",
    "description": "A grocery product.",
    "category": "groceries",
    "price": 1.99,
    "rating": 4.0,
    "stock": 100,
    "thumbnail": "https://cdn.dummyjson.com/thumb2.png"
  }]
}
""".trimIndent()

// ─── Helpers ─────────────────────────────────────────────────────────────────

/** Creates a [ProductRepository] backed by a [MockEngine] that always returns [responseBody]. */
private fun mockRepository(responseBody: String): ProductRepository {
    val engine = MockEngine { _ ->
        respond(
            content = responseBody,
            status = HttpStatusCode.OK,
            headers = headersOf(HttpHeaders.ContentType, "application/json")
        )
    }
    return ProductRepository(
        httpClient = HttpClient(engine) {
            install(ContentNegotiation) {
                json(Json { ignoreUnknownKeys = true })
            }
        }
    )
}

// ─── Tests ───────────────────────────────────────────────────────────────────

class ProductRepositoryTest {

    /** Verifies the repository returns the correct number of products from the parsed response. */
    @Test
    fun testFetchProducts_returnsCorrectCount() = runTest {
        val products = mockRepository(MOCK_PRODUCT_JSON).fetchProducts()
        assertEquals(1, products.size)
    }

    /** Verifies that the product title is correctly deserialized from JSON. */
    @Test
    fun testFetchProducts_parsesTitle() = runTest {
        val products = mockRepository(MOCK_PRODUCT_JSON).fetchProducts()
        assertEquals("Essence Mascara", products.first().title)
    }

    /**
     * Verifies that products without a `brand` field deserialize successfully.
     * The `brand` property is nullable (String? = null) in the data class,
     * so missing JSON keys should not cause a parsing error.
     */
    @Test
    fun testFetchProducts_handlesNullBrand() = runTest {
        val products = mockRepository(NO_BRAND_JSON).fetchProducts()
        assertEquals(1, products.size)
        assertNull(products.first().brand)
    }
}
