// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Primitives
import GemstonePrimitives
@testable import TransactionService

@MainActor
struct PollIntervalCalculatorTests {
    let config = TimerPollerConfiguration(
        maxInterval: .seconds(10),
        idleInterval: .seconds(5),
        stepFactor: 1.5
    )

    var solanaBlockTime: Duration {
        .milliseconds(ChainConfig.config(chain: .solana).blockTime)
    }

    var btcBlockTime: Duration {
        .milliseconds(ChainConfig.config(chain: .bitcoin).blockTime)
    }

    var ethBlockTime: Duration {
        .milliseconds(ChainConfig.config(chain: .ethereum).blockTime)
    }

    @Test
    func testImmediateDrop() async {
        let result = PollIntervalCalculator.nextInterval(
            configuration: config,
            currentInterval: .seconds(5),
            recommendedInterval: .seconds(3)
        )
        #expect(result == .seconds(3))
    }

    @Test
    func testStepUp() async {
        let result = PollIntervalCalculator.nextInterval(
            configuration: config,
            currentInterval: .seconds(3),
            recommendedInterval: .seconds(8)
        )
        #expect(result == .seconds(4.5))
    }

    @Test
    func testSameDurationSetupUp() async {
        let result = PollIntervalCalculator.nextInterval(
            configuration: config,
            currentInterval: .seconds(5),
            recommendedInterval: .seconds(5)
        )
        #expect(result == .seconds(7.5))
    }

    @Test
    func testBlockTimeAboveMax() async {
        let result = PollIntervalCalculator.nextInterval(
            configuration: config,
            currentInterval: .seconds(10),
            recommendedInterval: .seconds(600)
        )
        #expect(result == config.maxInterval)
    }

    @Test
    func testMaxCapping() async {
        let result = PollIntervalCalculator.nextInterval(
            configuration: config,
            currentInterval: .seconds(7),
            recommendedInterval: .seconds(9)
        )
        #expect(result == .seconds(10))
    }

    @Test
    func testImmediateDropMilliseconds() async {
        let result = PollIntervalCalculator.nextInterval(
            configuration: config,
            currentInterval: .milliseconds(1000),  // 1 second
            recommendedInterval: .milliseconds(500)    // 0.5 seconds
        )
        #expect(result == .milliseconds(500))
    }

    @Test
    func testStepUpMilliseconds() async {
        // Calculation: 500ms * 1.5 = 750ms, then max(750, 800) = 800ms.
        let result = PollIntervalCalculator.nextInterval(
            configuration: config,
            currentInterval: .milliseconds(500),
            recommendedInterval: .milliseconds(800)
        )
        #expect(result == .milliseconds(800))
    }

    @Test
    func testSolanaImmediateDrop() async {
        let result = PollIntervalCalculator.nextInterval(
            configuration: config,
            currentInterval: .seconds(5),
            recommendedInterval: solanaBlockTime
        )
        #expect(result == solanaBlockTime)
    }

    @Test
    func testBitcoinStepUp() async {
        // For Bitcoin, assume blockTime is 600s.
        // With current interval 8s, since 600s > maxInterval, result should be capped to 10s.
        let result = PollIntervalCalculator.nextInterval(
            configuration: config,
            currentInterval: .seconds(8),
            recommendedInterval: btcBlockTime
        )
        #expect(result == .seconds(10))
    }

    @Test
    func testEthereumStepUp() async {
        // For Ethereum, assume blockTime is 12s.
        // With current interval 2s, since 12s > maxInterval (10s), result should be capped to 10s.
        let result = PollIntervalCalculator.nextInterval(
            configuration: config,
            currentInterval: .seconds(2),
            recommendedInterval: ethBlockTime
        )
        #expect(result == .seconds(10))
    }

    @Test
    func testEthereumWithinAllowedRange() async {
        // Test a case with a hypothetical Ethereum block time below max.
        // For instance, if we simulate a 4s block time with current interval 3s:
        // Calculation: 3s * 1.5 = 4.5s, then max(4.5, 4) = 4.5s.
        let result = PollIntervalCalculator.nextInterval(
            configuration: config,
            currentInterval: .seconds(3),
            recommendedInterval: .seconds(4)
        )
        #expect(result == .seconds(4))
    }

    @Test
    func testStepUpWithinAllowedRange() async {
        let result = PollIntervalCalculator.nextInterval(
            configuration: config,
            currentInterval: .seconds(2),
            recommendedInterval: .seconds(3)
        )
        #expect(result == .seconds(3))
    }

    @Test
    func testSequentialStepUp() async {
        let step1 = PollIntervalCalculator.nextInterval(
            configuration: config,
            currentInterval: .seconds(5),
            recommendedInterval: .seconds(5)
        )
        #expect(step1 == .seconds(7.5))

        let step2 = PollIntervalCalculator.nextInterval(
            configuration: config,
            currentInterval: step1,
            recommendedInterval: .seconds(5)
        )
        #expect(step2 == .seconds(10))
    }
}
