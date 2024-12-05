// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import SwiftHTTPClient
import Primitives
import GemstonePrimitives
import BigInt
import SwiftUI
@testable import Blockchain

class EthereumFeeServiceTests {
    static let chain: EVMChain = .ethereum
    static let config = GemstoneConfig.shared.config(for: chain)
    static let provider: Provider<EthereumProvider> = ProviderFactory.create(with: chain.chain.defaultBaseUrl)
    static let service = EthereumService(chain: chain, provider: provider)

    @Test
    func tesCaluculatePriorityFeesFromRPC() throws {
        guard let jsonURL = Bundle.module.url(forResource: "EthereumFeeHistory", withExtension: "json") else {
            throw AnyError("can't access EthereumFeeHistory.json")
        }
        let jsonData = try Data(contentsOf: jsonURL)
        let response = try JSONDecoder().decode(
            JSONRPCResponse<EthereumFeeHistory>.self,
            from: jsonData
        )

        let rewards = response.result.reward.toBigInts()
        let slowFees = rewards.compactMap { $0[safe: 0] }
        let normalFees = rewards.compactMap { $0[safe: 1] }
        let fastFees = rewards.compactMap { $0[safe: 2] }

        let expectedSlowFee = slowFees.reduce(BigInt(0), +) / BigInt(slowFees.count)
        let expectedNormalFee = normalFees.reduce(BigInt(0), +) / BigInt(normalFees.count)
        let expectedFastFee = fastFees.reduce(BigInt(0), +) / BigInt(fastFees.count)

        let expectedFees: [FeePriority: BigInt] = [
            .slow: expectedSlowFee,
            .normal: expectedNormalFee,
            .fast: expectedFastFee
        ]
        let priorityFees = Self.service.calculatePriorityFees(
            rewards: rewards,
            rewardsPercentiles: Self.config.rewardsPercentiles,
            minPriorityFee: Self.config.minPriorityFee.asBigInt
        )

        #expect(priorityFees[.slow] == expectedFees[.slow])
        #expect(priorityFees[.normal] == expectedFees[.normal])
        #expect(priorityFees[.fast] == expectedFees[.fast])
    }

    @Test
    func testCalculatePriorityFeesWith1BlockRewards() {
        let rewards = [[1_000_000_000, 2_000_000_000, 3_000_000_000].map({ $0.asBigInt })]
        let config = GemstoneConfig.shared.config(for: Self.chain)
        let priorityFees = Self.service.calculatePriorityFees(
            rewards: rewards,
            rewardsPercentiles: config.rewardsPercentiles,
            minPriorityFee: config.minPriorityFee.asBigInt
        )

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
    func testCalculatePriorityFeesWith2BlockRewards() {
        let rewards = [
            [1_000_000_000, 2_000_000_000, 3_000_000_000].map({ $0.asBigInt }),
            [2_000_000_000, 0, 4_000_000_000].map({ $0.asBigInt }),
        ]
        let config = GemstoneConfig.shared.config(for: Self.chain)
        let priorityFees = Self.service.calculatePriorityFees(
            rewards: rewards,
            rewardsPercentiles: config.rewardsPercentiles,
            minPriorityFee: config.minPriorityFee.asBigInt
        )

        let expectedFees: [FeePriority: BigInt] = [
            .slow: 1_500_000_000.asBigInt,
            .normal: 1_000_000_000.asBigInt,
            .fast: 3_500_000_000.asBigInt
        ]

        #expect(priorityFees[.slow] == expectedFees[.slow])
        #expect(priorityFees[.normal] == expectedFees[.normal])
        #expect(priorityFees[.fast] == expectedFees[.fast])
    }

    @Test
    func testCalculatePriorityFeesEmptyRewards() {
        let config = GemstoneConfig.shared.config(for: Self.chain)
        let priorityFees = Self.service.calculatePriorityFees(
            rewards: [],
            rewardsPercentiles: config.rewardsPercentiles,
            minPriorityFee: config.minPriorityFee.asBigInt
        )

        let expectedFees: [FeePriority: BigInt] = [
            .slow: config.minPriorityFee.asBigInt,
            .normal: config.minPriorityFee.asBigInt,
            .fast: config.minPriorityFee.asBigInt
        ]

        #expect(priorityFees[.slow] == expectedFees[.slow])
        #expect(priorityFees[.normal] == expectedFees[.normal])
        #expect(priorityFees[.fast] == expectedFees[.fast])
    }
}
