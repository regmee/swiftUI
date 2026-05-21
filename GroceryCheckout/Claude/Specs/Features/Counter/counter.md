# Spec: Counter

**Status:** Draft
**Owner:** you
**Feature folder:** `GroceryCheckout/Features/Counter/`
**Test folder:** `GroceryCheckoutTests/Features/Counter/`
**Test framework:** Swift Testing

## Summary

A single screen that displays an integer counter and lets the user increment,
decrement, or reset it. First feature in the app — also serves as the
reference implementation of the MVVM pattern for GroceryCheckout.

## User stories

- As a user, I see the current count when the screen opens.
- As a user, I can tap "+" to increase the count by 1.
- As a user, I can tap "−" to decrease the count by 1.
- As a user, I can tap "Reset" to set the count back to zero.

## Behavior

| Action     | Precondition       | Postcondition                  |
| ---------- | ------------------ | ------------------------------ |
| open       | —                  | `count == 0`                   |
| increment  | `count < Int.max`  | `count` increases by 1         |
| decrement  | `count > 0`        | `count` decreases by 1         |
| decrement  | `count == 0`       | `count` stays at 0 (no-op)     |
| reset      | any                | `count == 0`                   |

The counter is not persisted across app launches. State lives in memory only.

## Out of scope

- Persistence (UserDefaults, SwiftData) — no Service needed for this feature
- Custom step sizes
- Negative numbers
- Animations beyond SwiftUI defaults
- Accessibility labels beyond what SwiftUI provides by default

## Files to produce

Per `Claude/Skills/SKILL.md`. Because this feature has no I/O,
**no Service is needed.**

- `GroceryCheckout/Features/Counter/ViewModels/CounterViewModel.swift`
- `GroceryCheckoutTests/Features/Counter/CounterViewModelTests.swift`
- `GroceryCheckout/Features/Counter/Views/CounterView.swift`

## UI requirements

- Count is shown centered, large font (`.largeTitle`, bold).
- Three buttons in a horizontal row below the count: `−`, `Reset`, `+`.
- The `−` button is disabled when `viewModel.canDecrement == false`.
- No navigation. Hosted by `ContentView` as the root for now.

## Acceptance tests

These must exist in `CounterViewModelTests.swift` (Swift Testing, `@MainActor`)
and pass:

1. `initialCountIsZero` — fresh VM has `count == 0`.
2. `incrementFromZeroSetsCountToOne`.
3. `incrementFromFiveSetsCountToSix`.
4. `decrementAtZeroKeepsCountAtZero`.
5. `decrementFromThreeSetsCountToTwo`.
6. `resetFromTenSetsCountToZero`.
7. `canDecrementIsFalseWhenAtZero`.
8. `canDecrementIsTrueWhenAboveZero`.

## Open questions

None. If something is unclear during implementation, stop and ask.
