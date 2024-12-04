// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import SwiftHTTPClient
import Primitives
import GemstonePrimitives
import BigInt
@testable import Blockchain

struct EthereumFeeServiceTests {
    static let chain: EVMChain = .ethereum
    static let provider: Provider<EthereumProvider> = ProviderFactory.create(with: chain.chain.defaultBaseUrl)
    static let config = GemstoneConfig.shared.config(for: chain)
    static let service = EthereumService(chain: chain, provider: provider)

    @Test
    func testCalculatePriorityFeesWith1BlockRewards() {
        let rewards = [["0x3b9aca00", "0x77359400", "0xb2d05e00"]] // 1 2 3
        let priorityFees = Self.service.calculatePriorityFees(rewards: rewards, config: Self.config)

        let expectedFees: [FeePriority: BigInt] = [
            .slow: 1_000_000_000.asBigInt,
            .normal: 2_000_000_000.asBigInt,
            .fast: 3_000_000_000.asBigInt
        ]

        #expect(priorityFees[.slow] == expectedFees[.slow])
        #expect(priorityFees[.normal] == expectedFees[.normal])
        #expect(priorityFees[.fast] == expectedFees[.fast])
    }

    @Test
    func testCalculatePriorityFeesWith10BlockRewards() {
        let rewards = [
            ["0x268e8907", "0x73a20d00", "0xb2d05e00"],
            ["0x4804041",  "0x3b9aca00", "0x77359400"],
            ["0x3b9aca00", "0x73a20d00", "0xc1c17258"],
            ["0x28761610", "0x73a20d00", "0xaef97b2d"],
            ["0x0",        "0x6f7baf7e", "0x12a05f200"],
            ["0x3b9aca00", "0x7029fd40", "0xb5c08be2"],
            ["0x3b9aca00", "0x72c77a9b", "0xb5c08be2"],
            ["0x3b9aca00", "0x73a20d00", "0xbd86f9f3"],
            ["0x5f5e100",  "0x73a20d00", "0xc1e397db"],
            ["0x5f5e100",  "0x73a20d00", "0xc3b67b4c"]
        ]

        let slowFees = rewards.compactMap { blockRewards -> BigInt? in
            guard let feeHex = blockRewards[safe: 0] else { return nil }
            return try? BigInt.fromHex(feeHex)
        }
        let normalFees = rewards.compactMap { blockRewards -> BigInt? in
            guard let feeHex = blockRewards[safe: 1] else { return nil }
            return try? BigInt.fromHex(feeHex)
        }
        let fastFees = rewards.compactMap { blockRewards -> BigInt? in
            guard let feeHex = blockRewards[safe: 2] else { return nil }
            return try? BigInt.fromHex(feeHex)
        }

        let expectedSlowFee = slowFees.reduce(BigInt(0), +) / BigInt(slowFees.count)
        let expectedNormalFee = normalFees.reduce(BigInt(0), +) / BigInt(normalFees.count)
        let expectedFastFee = fastFees.reduce(BigInt(0), +) / BigInt(fastFees.count)

        let expectedFees: [FeePriority: BigInt] = [
            .slow: expectedSlowFee,
            .normal: expectedNormalFee,
            .fast: expectedFastFee
        ]
        let priorityFees = EthereumFeeServiceTests.service.calculatePriorityFees(
            rewards: rewards,
            config: EthereumFeeServiceTests.config
        )
        #expect(priorityFees[.slow] == expectedFees[.slow])
        #expect(priorityFees[.normal] == expectedFees[.normal])
        #expect(priorityFees[.fast] == expectedFees[.fast])
    }

    @Test
    func testCalculatePriorityFeesEmptyRewards() {
        let priorityFees = Self.service.calculatePriorityFees(rewards: [], config: Self.config)
        let expectedFees: [FeePriority: BigInt] = [
            .slow: Self.config.minPriorityFee.asBigInt,
            .normal: Self.config.minPriorityFee.asBigInt,
            .fast: Self.config.minPriorityFee.asBigInt
        ]

        #expect(priorityFees[.slow] == expectedFees[.slow])
        #expect(priorityFees[.normal] == expectedFees[.normal])
        #expect(priorityFees[.fast] == expectedFees[.fast])
    }
}
