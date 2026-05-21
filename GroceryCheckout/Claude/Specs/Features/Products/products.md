# Spec: Products

**Status:** Draft
**Owner:** you
**Feature folder:** `GroceryCheckout/Features/Products/`
**Test folder:** `GroceryCheckoutTests/Features/Products/`
**Test framework:** Swift Testing

## Summary

A single screen that displays a list of products. Users can select product row and view product details. Second feature in the app. Let's creat app as a TabView and have this as second tab.

## User stories

- As a user, I see the Products list when the screen opens.
- As a user, I can tap product row to view product detail page and navigate back with top left navigation bar back button.

## Behavior

The list of products is not persisted across app launches. State lives in memory only. Network Service needed to download JSON data from https://dummyjson.com/products?limit=20
This features needs IO to download and parse JSON from the URL above.
This network service will be used on other REST API calls as well and therefore the Data downloader and Data parser needs to be put in GroceryCheckout/Core/ folder.
All types of Errors to be handled properly. Errors from lower layers propagate upto ViewModel where they are handled and elegantly presented in the View.

## Out of scope

- Persistence (UserDefaults, SwiftData)
- Animations beyond SwiftUI defaults
- Accessibility labels beyond what SwiftUI provides by default

## Files to produce

Per `Claude/Skills/SKILL.md`. Because this feature has I/O, **NetworkService is needed.**

- `GroceryCheckout/Features/Products/ViewModels/ProductsListViewModel.swift`
- `GroceryCheckoutTests/Features/Products/ProductsListViewModelTests.swift`
- `GroceryCheckout/Features/Products/Views/ProductsListView.swift`
- `GroceryCheckout/Features/Products/Views/ProductsListRowView.swift`
- `GroceryCheckout/Features/Products/Views/ProductsListDetailView.swift`
- `GroceryCheckout/Core/Network/NetworkService.swift`

NetworkService to implement NetworkServiceProtocol and this helps in creating a MockNetworkService for unit tests.

## UI requirements

- ListViewRow has title, description, category, rating, stock and uses thumbnail URL for AsynImage with suitable placeholder to avoid the jank.
- The UI resides on second Tab and on Row selection it moves to detail page that has full detail of the product.


## Acceptance tests

These must exist in `ProductsListViewModelTests.swift` (Swift Testing, `@MainActor`)
and pass:

1. loadProducts_onSuccess_populatesProducts // happy path: products end up in the VM after a successful fetch.
2. loadProducts_onNetworkError_setsUserFacingErrorMessage // network failures surface as a friendly message, not a crash or silent fail.
3. loadProducts_onDecodingError_setsUserFacingErrorMessage // bad JSON is handled distinctly from network errors so the user (and you) know which layer broke.
4. parse_withMalformedJSON_throwsDecodingError // proves the Core parser rejects garbage rather than producing half-built models that explode later.
5. selectProduct_setsSelectedProduct // the only piece of interaction state in the feature; without this test, tap-to-detail can silently break.

## Open questions

None. If something is unclear during implementation, stop and ask.
