---
name: swiftui-mvvm-feature
description: Use whenever generating a new SwiftUI feature in GroceryCheckout — a View, ViewModel, optional Service, and matching tests. Trigger on any request to "add a screen", "build a feature", "create a view", or implement anything described in Claude/Specs/Features/. Do not use for pure model/struct work or non-SwiftUI Swift code.
---

# SwiftUI MVVM Feature Skill (GroceryCheckout)

Generates a feature trio (or quartet, with a Service) in the exact shape this
project requires. Read this file in full before writing any feature code.

## When to use

Triggered when the user asks for a new feature, screen, or component. Always
produces files in this order:

0. **Log the prompt first** (see "Prompt logging" below). This happens BEFORE
   any code is written.
1. `Features/<Feature>/Models/<Name>.swift` — if a new model type is needed
2. `Features/<Feature>/Services/<Name>Service.swift` — if I/O is required
3. `Features/<Feature>/ViewModels/<Name>ViewModel.swift`
4. `GroceryCheckoutTests/Features/<Feature>/<Name>ServiceTests.swift` — if a Service exists
5. `GroceryCheckoutTests/Features/<Feature>/<Name>ViewModelTests.swift`
6. `Features/<Feature>/Views/<Name>View.swift`

Service → ViewModel → View, with tests interleaved. Never reverse.

## Prompt logging

Every feature-implementation prompt MUST be appended to
`Claude/Prompts/PromptsN.csv` BEFORE writing any code.

**Columns:** `date,author,prompt` (header row exactly).

**Step-by-step procedure**

1. Find the active prompts file:

   ```bash
   ls Claude/Prompts/ 2>/dev/null | grep -E '^Prompts[0-9]+\.csv$' | sort -V | tail -1
   ```

2. If no file exists, create `Claude/Prompts/Prompts1.csv` with just the
   header:

   ```bash
   mkdir -p Claude/Prompts
   echo 'date,author,prompt' > Claude/Prompts/Prompts1.csv
   ```

3. Count rows in the active file (excluding header):

   ```bash
   DATA_ROWS=$(($(wc -l < Claude/Prompts/PromptsN.csv) - 1))
   ```

4. If `DATA_ROWS >= 100`, roll over: extract `N` from the filename,
   compute `N+1`, and create the next file with only the header:

   ```bash
   echo 'date,author,prompt' > Claude/Prompts/Prompts<N+1>.csv
   ```

   Use the new file for this and future appends.

5. Append the new row. Build the row carefully:

   - **date**: ISO 8601 local time, `YYYY-MM-DD HH:MM`. Get it with
     `date '+%Y-%m-%d %H:%M'`.
   - **author**: the user's name. If unknown, ask the user once before
     proceeding and remember for the rest of the session.
   - **prompt**: the user's full message, with every `"` replaced by `""`,
     then wrapped in `"..."`. Preserve newlines as literal newlines inside
     the quotes (CSV allows this).

   Use a heredoc to write the row safely:

   ```bash
   cat >> Claude/Prompts/PromptsN.csv <<'EOF'
   2026-05-21 11:42,Jane Doe,"Implement @Claude/Specs/Features/Counter/counter.md"
   EOF
   ```

6. Confirm to the user briefly: "Logged to `Claude/Prompts/PromptsN.csv`
   (row M of 100)."

7. Then proceed with the rest of the feature generation.

**When NOT to log**

Skip the log for: small fixes, follow-up questions, clarifications,
rejections, requests to tweak generated code. Only log the prompts that
kick off a fresh feature implementation or a substantive change.

## Service template

Only create when the feature needs I/O (network, disk, database, system APIs).
A pure in-memory feature does not need a Service.

```swift
import Foundation

/// <One-line description of what this service does.>
protocol <Name>Service {
    func <method>() async throws -> <ReturnType>
}

final class Default<Name>Service: <Name>Service {

    // MARK: - Dependencies

    private let <dependency>: <DependencyType>

    // MARK: - Init

    init(<dependency>: <DependencyType>) {
        self.<dependency> = <dependency>
    }

    // MARK: - <Name>Service

    func <method>() async throws -> <ReturnType> {
        // I/O happens here
    }
}
```

Rules:
- Always define a protocol so the ViewModel can be tested with a fake.
- Concrete type is named `Default<Name>Service`.
- Service has no SwiftUI imports. Ever.
- Service is NOT `@MainActor`. It runs off-main so I/O does not block the UI.
- If the service holds shared mutable state (cache, in-flight requests), make
  it an `actor` instead of a `final class` — see Actor template below.

## Actor template (use when there is shared mutable state)

Reach for `actor` whenever two or more `Task`s could touch the same property.
Typical cases: caches, in-flight request maps, counters, queues, anything
where `final class` would invite a race.

```swift
import Foundation

/// <One-line description of what this actor protects.>
actor <Name>Cache {

    // MARK: - State (protected by actor isolation)

    private var storage: [String: <ValueType>] = [:]

    // MARK: - API

    func value(for key: String) -> <ValueType>? {
        storage[key]
    }

    func set(_ value: <ValueType>, for key: String) {
        storage[key] = value
    }
}
```

Rules:
- Properties are `private`. Mutation only via the actor's own methods.
- Stored values must be `Sendable` (use value types where possible).
- Callers `await` every actor method — even reads.
- Do NOT mark actor methods `nonisolated` unless they touch zero `self` state.
- If the actor is used by a `@MainActor` ViewModel, the VM just `await`s it;
  no extra hops needed.

## Sendable cheat-sheet

- `struct` of `Sendable` fields → automatically `Sendable`.
- `enum` with `Sendable` associated values → automatically `Sendable`.
- `final class` → declare `Sendable` explicitly; all stored properties must be
  `let` and `Sendable`.
- Anything mutable shared across tasks → make it an `actor`, not `@unchecked Sendable`.

## ViewModel template

```swift
import Foundation
import Observation

/// <One-line description of what this VM owns.>
@MainActor
@Observable
final class <Name>ViewModel {

    // MARK: - State (read by the View)

    private(set) var <stateProperty>: <Type> = <default>

    // MARK: - Dependencies

    private let service: <Name>Service

    // MARK: - Init

    init(service: <Name>Service = Default<Name>Service()) {
        self.service = service
    }

    // MARK: - Intents (called by the View)

    func <intentMethod>() {
        // mutate state here, delegate I/O to service
    }
}
```

Rules:
- `@MainActor` is required. UI state mutations must happen on the main thread.
- State properties are `private(set) var` so views read but cannot write.
- Intents are verbs: `increment()`, `loadItems()`, `submitOrder()`.
- Async intents are plain `func foo() async` — being on `@MainActor` already
  guarantees state mutations happen on main after each `await`.
- Never expose dependencies publicly.
- No SwiftUI imports.

## View template

```swift
import SwiftUI

struct <Name>View: View {

    @State private var viewModel: <Name>ViewModel

    init(viewModel: <Name>ViewModel = <Name>ViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        // Compose subviews. No logic. No computed `if` chains over 3 cases —
        // push that into the ViewModel as a computed property.
    }
}

#Preview {
    <Name>View()
}
```

Rules:
- View takes its ViewModel via init with a default. This makes previews easy
  and tests possible.
- Use `@State` with `@Observable` ViewModels (iOS 17+). Do not use `@StateObject`.
- Always include a `#Preview`.

## Test templates

**The spec declares which framework to use.** Read the spec's
`Test framework:` field before writing any test file. Never mix frameworks in
one file. If the spec is silent, stop and ask.

### Swift Testing template

```swift
import Testing
@testable import GroceryCheckout

@MainActor
struct <Name>ViewModelTests {

    @Test
    func incrementFromZeroSetsCountToOne() {
        // Arrange
        let sut = <Name>ViewModel(service: Fake<Name>Service())

        // Act
        sut.increment()

        // Assert
        #expect(sut.count == 1)
    }
}

// MARK: - Fakes

private final class Fake<Name>Service: <Name>Service, @unchecked Sendable {
    var stubbedResult: <ReturnType> = <default>
    func <method>() async throws -> <ReturnType> { stubbedResult }
}
```

Rules:
- `import Testing`, not `XCTest`.
- The test type is a `struct`, not a class.
- `@MainActor` on the test type when testing a `@MainActor` ViewModel.
- Use `@Test` on each test function. Function names are descriptive
  (no `test_` prefix).
- Use `#expect(...)` for assertions, `#require(...)` for preconditions that
  must hold for the test to continue.
- Async tests: just mark the function `async`.

### XCTest template

```swift
import XCTest
@testable import GroceryCheckout

@MainActor
final class <Name>ViewModelTests: XCTestCase {

    func test_increment_whenAtZero_setsCountToOne() {
        // Arrange
        let sut = <Name>ViewModel(service: Fake<Name>Service())

        // Act
        sut.increment()

        // Assert
        XCTAssertEqual(sut.count, 1)
    }
}

// MARK: - Fakes

private final class Fake<Name>Service: <Name>Service, @unchecked Sendable {
    var stubbedResult: <ReturnType> = <default>
    func <method>() async throws -> <ReturnType> { stubbedResult }
}
```

Rules:
- `import XCTest`.
- The test class is `final class ...: XCTestCase`.
- `@MainActor` on the class when testing a `@MainActor` ViewModel.
- Method names follow `test_<methodUnderTest>_<scenario>_<expectedResult>`.
- Use `XCTAssertEqual`, `XCTAssertTrue`, etc.
- Async tests: `func test_...() async throws`.

### Shared test rules (both frameworks)

- `sut` = "system under test". Always use this name for the instance being tested.
- Cover: initial state, each intent, edge cases listed in the spec.
- Inject a fake/spy for any Service dependency. Do not use a mocking framework
  — write a small fake class in the same test file (`private final class`).
- Service tests live in `<Name>ServiceTests.swift` and exercise the real
  service with a fake of its lower-level dependency.
- Actor tests must include at least one test that spawns multiple concurrent
  `Task`s to exercise isolation.

## Worked example

For a request "add the Counter feature" against
`Claude/Specs/Features/Counter/counter.md`, and assuming no Service is needed,
generate in this order:

0. Append a row to `Claude/Prompts/Prompts1.csv` with the user's prompt.
1. `Features/Counter/ViewModels/CounterViewModel.swift` — has `count: Int`,
   `increment()`, `decrement()`, `reset()`, `canDecrement: Bool`.
2. `GroceryCheckoutTests/Features/Counter/CounterViewModelTests.swift` — tests
   for initial state, each intent, the `canDecrement` computed property.
3. `Features/Counter/Views/CounterView.swift` — displays `viewModel.count`,
   three buttons calling the intents, `−` disabled when `!viewModel.canDecrement`.

## Output checklist

Before considering a feature done, verify:

- [ ] The prompt was logged to `Claude/Prompts/PromptsN.csv`.
- [ ] All new code files live under `GroceryCheckout/Features/<Feature>/<Layer>/`.
- [ ] Tests live under `GroceryCheckoutTests/Features/<Feature>/`.
- [ ] Service (if any) has no SwiftUI imports.
- [ ] ViewModel is `@MainActor` and has no SwiftUI imports.
- [ ] Any shared mutable state is wrapped in an `actor`, not a `final class`.
- [ ] No `DispatchQueue.main.async` anywhere — use `@MainActor` / `MainActor.run`.
- [ ] No `@unchecked Sendable` outside test fakes (and only with comment).
- [ ] Test framework matches the spec's `Test framework:` field.
- [ ] View has no business logic (no `if` chains, no math, no I/O).
- [ ] Every public intent on the ViewModel has at least one test.
- [ ] If a Service exists, it has its own test file.
- [ ] If an actor exists, it has a concurrency test (multiple tasks).
- [ ] File names match type names exactly.
- [ ] `#Preview` is present and compiles.
- [ ] No force-unwraps outside tests.
- [ ] No imports from sibling features.

If any box is unchecked, fix before reporting completion.
