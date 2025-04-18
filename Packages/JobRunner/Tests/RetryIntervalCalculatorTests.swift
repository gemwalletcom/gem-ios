// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
@testable import JobRunner

@MainActor
struct RetryIntervalCalculatorTests {
    let fixedConfig = JobRunnerConfiguration.fixed(.seconds(5))
    let adaptiveConfig = JobRunnerConfiguration.adaptive(
        AdaptiveConfiguration(
            idleInterval: .seconds(5),
            maxInterval: .seconds(10),
            stepFactor: 1.5
        )
    )
    @Test
    func testFixedIgnoreRequestedInterval() async {
        let result = RetryIntervalCalculator.nextInterval(
            config: fixedConfig,
            currentInterval: .seconds(2),
            requestedDelay: .seconds(3)
        )
        #expect(result == .seconds(5))
    }

    @Test
    func testFixedHugeRequestedInterval() async {
        let result = RetryIntervalCalculator.nextInterval(
            config: fixedConfig,
            currentInterval: .seconds(2),
            requestedDelay: .seconds(999)
        )
        #expect(result == .seconds(5))
    }

    @Test
    func testAdaptiveImmediateDrop() async {
        let result = RetryIntervalCalculator.nextInterval(
            config: adaptiveConfig,
            currentInterval: .seconds(5),
            requestedDelay: .seconds(3)
        )
        #expect(result == .seconds(3))
    }

    @Test
    func testAdaptiveClampingToMax() async {
        let result = RetryIntervalCalculator.nextInterval(
            config: adaptiveConfig,
            currentInterval: .seconds(5),
            requestedDelay: .seconds(999)
        )
        #expect(result == .seconds(10))
    }

    @Test
    func testAdaptiveStepFactorGrowth() async {
        // recommended(8s) => above idle(5s), below max(10s)
        // current(5s) * 1.5 => 7.5 => < recommended(8)
        // So we pick 7.5
        let result = RetryIntervalCalculator.nextInterval(
            config: adaptiveConfig,
            currentInterval: .seconds(5),
            requestedDelay: .seconds(8)
        )
        #expect(result == .seconds(7.5))
    }

    @Test
    func testAdaptiveTwoStep() async {
        let first = RetryIntervalCalculator.nextInterval(
            config: adaptiveConfig,
            currentInterval: .seconds(5),
            requestedDelay: .seconds(5)
        )
        #expect(first == .seconds(7.5))

        let second = RetryIntervalCalculator.nextInterval(
            config: adaptiveConfig,
            currentInterval: first,
            requestedDelay: .seconds(5)
        )
        #expect(second == .seconds(10))
    }

    @Test
    func testAdaptiveBelowIdleInMilliseconds() async {
        let result = RetryIntervalCalculator.nextInterval(
            config: adaptiveConfig,
            currentInterval: .milliseconds(2500),
            requestedDelay: .milliseconds(500)
        )
        #expect(result == .milliseconds(500))
    }

    @Test
    func testAdaptiveStepUpClampToMax() async {
        let result = RetryIntervalCalculator.nextInterval(
            config: adaptiveConfig,
            currentInterval: .seconds(7),
            requestedDelay: .seconds(9)
        )
        #expect(result == .seconds(10))
    }
}
