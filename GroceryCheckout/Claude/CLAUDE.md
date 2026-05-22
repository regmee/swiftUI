# Project: GroceryCheckout

A SwiftUI app organized **by feature**, not by type. This file is the entry
point for any AI assistant working in this repo. Read it first, every session.

All AI-assistant config lives under `Claude/` at the project root:
- `Claude/CLAUDE.md` — this file (project-wide rules)
- `Claude/Skills/SKILL.md` — code patterns and templates
- `Claude/Specs/Features/<Feature>/<feature>.md` — one spec per feature
- `Claude/Prompts/PromptsN.csv` — log of all feature-implementation prompts

## Project layout

```
GroceryCheckout/                          (repo root)
├── Claude/
│   ├── CLAUDE.md                         This file
│   ├── Skills/
│   │   └── SKILL.md                      Code patterns — read before generating
│   ├── Specs/
│   │   └── Features/
│   │       └── <Feature>/<feature>.md    One spec per feature
│   └── Prompts/
│       ├── Prompts1.csv                  Append-only log, max 100 rows per file
│       ├── Prompts2.csv                  Roll over to next file at 100
│       └── ...
├── GroceryCheckout.xcodeproj
├── GroceryCheckout/                      Swift source
│   ├── App/
│   │   └── GroceryCheckoutApp.swift      @main entry point
│   ├── Features/                         All product features live here
│   │   ├── Counter/
│   │   │   ├── Models/
│   │   │   ├── Services/
│   │   │   ├── ViewModels/
│   │   │   └── Views/
│   │   ├── Favs/
│   │   ├── GroceryList/
│   │   └── Home/
│   ├── Assets.xcassets
│   └── ContentView.swift                 Root view, hosts features
├── GroceryCheckoutTests/                 Unit tests (mirrors Features/)
└── GroceryCheckoutUITests/               XCUITest UI tests
```

## Architecture rules

- **Feature-first.** Each feature is self-contained under
  `GroceryCheckout/Features/<Name>/` with its own `Models/`, `Services/`,
  `ViewModels/`, `Views/` subfolders. Never reach across features — if Counter
  needs something from GroceryList, promote it to a shared module (ask first).
- **MVVM + Services.** Views are dumb. State lives in a `ViewModel`. Models
  are value types (`struct`). Services are protocol-backed classes that handle
  I/O, persistence, or external APIs.
- **No business logic in Views.** A view may format data for display, but any
  computation, mutation, or side effect goes through the ViewModel.
- **No I/O in ViewModels.** Network, disk, or database access goes through a
  Service injected into the ViewModel.
- **One type per file.** File name matches the type name.
- **Dependency injection via init.** No singletons. No `@EnvironmentObject`
  unless explicitly approved.

## Concurrency rules

- **Project uses Swift 6 language mode** (set in Build Settings → Swift Language
  Version → Swift 6, for app + test + UITest targets). All generated code MUST
  compile under strict concurrency checking — no data races, no implicit
  global-actor violations. Treat every Sendable and actor-isolation warning as
  an error to fix, not ignore.
- **ViewModels are `@MainActor`.** They drive UI updates which must happen on
  the main thread. Mark every ViewModel class `@MainActor`.
- **Services are NOT `@MainActor`** by default. They run off the main thread
  so I/O does not block the UI. The ViewModel hops back to main when it
  receives a result (it already is on main, so just `await` the service call).
- **Use `actor` for any shared mutable state accessed from multiple tasks.**
  Examples: in-memory caches, request deduplicators, counters incremented
  from concurrent callers, queues of pending writes. If two `Task`s could
  touch the same property, wrap it in an `actor`.
- **Use `Sendable` for types crossing concurrency boundaries.** Value types
  (`struct` of `Sendable` fields) get this for free; reference types need
  `final class` + explicit `Sendable` conformance and immutable state.
- **No `DispatchQueue.main.async`.** Use `await MainActor.run { ... }` or mark
  the target method `@MainActor` instead.
- **No `@unchecked Sendable`** without an explicit comment justifying it. If
  you reach for it, stop and ask.
- **Prefer `async/await` over completion handlers** for any new code.

## Coding style

- Swift 5.9+, iOS 17+. Prefer `@Observable` macro over `ObservableObject`.
- 4-space indentation. Line width 100.
- Use `// MARK: -` to separate sections inside files longer than 40 lines.
- Public API gets `///` doc comments. Internal helpers do not.
- No force-unwraps (`!`) except in tests. Use `guard let` or `if let`.
- Prefer `let` over `var`. Prefer trailing closures only when there is one closure argument.

## Testing rules

- **Test framework is per-spec.** Every spec declares `Test framework: Swift Testing`
  or `Test framework: XCTest`. Follow the spec — never mix frameworks in one
  test file. If a spec is silent, ask before writing tests.
- Tests mirror the feature layout:
  `GroceryCheckoutTests/Features/<Feature>/<Name>ViewModelTests.swift`.
- Every ViewModel has matching tests. Every Service has matching tests (with
  a fake/spy for its dependencies). Every `actor` has matching tests covering
  concurrent access.
- Naming:
  - Swift Testing: descriptive function names, e.g. `func incrementFromZeroSetsCountToOne()`.
  - XCTest: `test_<methodUnderTest>_<scenario>_<expectedResult>`,
    e.g. `test_increment_whenAtZero_setsCountToOne`.
- Arrange/Act/Assert with blank lines separating the three phases.
- One assertion per test where possible. Multiple assertions are OK only when
  asserting on different fields of the same resulting state.
- No tests for plain SwiftUI views — test the ViewModel instead. UI flows go
  in `GroceryCheckoutUITests/`.

## Prompt logging rules

Every prompt that triggers feature implementation (i.e. anything that causes
SKILL.md to fire) MUST be appended to the prompts log. This gives the project
a paper trail of every change request.

- **Location:** `Claude/Prompts/PromptsN.csv`, starting at `Prompts1.csv`.
- **Columns:** `date,author,prompt` — exactly these three, in this order.
- **Date format:** ISO 8601, `YYYY-MM-DD HH:MM` in local time.
- **Author:** the user's name. If unknown, ask once at the start of the
  session and remember it for subsequent prompts in the same session.
- **Prompt:** the user's full message, with double-quotes escaped as `""`
  and the whole field wrapped in double-quotes. Newlines preserved.
- **Rollover:** when the current file reaches 100 data rows (101 lines
  including the header), create the next numbered file
  (`Prompts2.csv`, `Prompts3.csv`, …) with the header row and start
  appending there.
- **Header row** in every new file:
  `date,author,prompt`
- **When NOT to log:** small fixes, questions, follow-up clarifications,
  rejections of generated code. Only log prompts that kick off a fresh
  feature implementation or a substantive change to one.
- **When to log:** BEFORE writing any code. The log entry is the first
  action; the code generation is the second.

See `Claude/Skills/SKILL.md` for the exact bash commands to use for
appending and rollover.

## Workflow

1. The user will reference a spec, typically like
   `@Claude/Specs/Features/<Feature>/<feature>.md`. Read it in full before
   writing any code.
2. **Log the prompt** to `Claude/Prompts/PromptsN.csv` per the prompt logging
   rules above. Confirm author if unknown.
3. Read `Claude/Skills/SKILL.md` for the exact code patterns to follow.
4. Place new files under `GroceryCheckout/Features/<Feature>/<Layer>/`.
5. Write the Service (if any) and its tests first.
6. Write the ViewModel and its tests next. Inject the Service.
7. Write the View last. Wire it to the ViewModel.
8. Never invent requirements. If a spec is ambiguous, ask before coding.

## What NOT to do

- Do not add third-party dependencies without asking.
- Do not introduce new architectural patterns (Redux, TCA, etc.) without asking.
- Do not modify files outside the feature you were asked to work on.
- Do not cross-import between sibling features (Counter ↔ Favs, etc.).
- Do not write code that isn't covered by either a spec or an explicit request.
- Do not skip the prompt log for feature-implementation prompts.
