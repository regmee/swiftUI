//  CounterViewModelTests.swift
//  GroceryCheckout
//
//  Created by AR on 2026-05-21.
//  Copyright © 2026 AR. All rights reserved.
//

import Testing
@testable import GroceryCheckout

@MainActor
struct CounterViewModelTests {

    @Test
    func initialCountIsZero() {
        // Arrange
        let sut = CounterViewModel()

        // Assert
        #expect(sut.count == 0)
    }

    @Test
    func incrementFromZeroSetsCountToOne() {
        // Arrange
        let sut = CounterViewModel()

        // Act
        sut.increment()

        // Assert
        #expect(sut.count == 1)
    }

    @Test
    func incrementFromFiveSetsCountToSix() {
        // Arrange
        let sut = CounterViewModel()
        for _ in 1...5 { sut.increment() }

        // Act
        sut.increment()

        // Assert
        #expect(sut.count == 6)
    }

    @Test
    func decrementAtZeroKeepsCountAtZero() {
        // Arrange
        let sut = CounterViewModel()

        // Act
        sut.decrement()

        // Assert
        #expect(sut.count == 0)
    }

    @Test
    func decrementFromThreeSetsCountToTwo() {
        // Arrange
        let sut = CounterViewModel()
        for _ in 1...3 { sut.increment() }

        // Act
        sut.decrement()

        // Assert
        #expect(sut.count == 2)
    }

    @Test
    func resetFromTenSetsCountToZero() {
        // Arrange
        let sut = CounterViewModel()
        for _ in 1...10 { sut.increment() }

        // Act
        sut.reset()

        // Assert
        #expect(sut.count == 0)
    }

    @Test
    func canDecrementIsFalseWhenAtZero() {
        // Arrange
        let sut = CounterViewModel()

        // Assert
        #expect(sut.canDecrement == false)
    }

    @Test
    func canDecrementIsTrueWhenAboveZero() {
        // Arrange
        let sut = CounterViewModel()

        // Act
        sut.increment()

        // Assert
        #expect(sut.canDecrement == true)
    }
}
