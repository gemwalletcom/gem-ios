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
    static let config = GemstoneConfig.shared.config(for: chain)
    static let provider: Provider<EthereumProvider> = ProviderFactory.create(with: chain.chain.defaultBaseUrl)
    static let service = EthereumService(chain: chain, provider: provider)

    @Test
    func tesCaluculatePriorityFeesFromRPC() throws {
        let json = """
    {
          "id": 1,
          "jsonrpc": "2.0",
          "result": {
            "baseFeePerBlobGas": [
              "0x248e3c17c",
              "0x278aaebf5",
              "0x2325f0a24",
              "0x278aaebf5",
              "0x2604f4d55",
              "0x2ac5937a3",
              "0x2604f4d55",
              "0x2ac5937a3",
              "0x301e45f40",
              "0x320b8540d",
              "0x2c7c04a10"
            ],
            "baseFeePerGas": [
              "0x4465f59e8",
              "0x402192bd1",
              "0x427bf0f31",
              "0x409ddd23b",
              "0x3ba845815",
              "0x4287505cf",
              "0x416cf8696",
              "0x4090ffdab",
              "0x3f7373d23",
              "0x3e788e1be",
              "0x406562ab1"
            ],
            "blobGasUsedRatio": [
              0.8333333333333334,
              0,
              1,
              0.3333333333333333,
              1,
              0,
              1,
              1,
              0.6666666666666666,
              0
            ],
            "gasUsedRatio": [
              0.2504537333333333,
              0.6467617666666666,
              0.387643,
              0.19299896666666666,
              0.9607153333333334,
              0.43368836666666666,
              0.4474664,
              0.4308979333333333,
              0.4382157666666667,
              0.6232649333333333
            ],
            "oldestBlock": "0x1458fd4",
            "reward": [
              [
                "0x123d7953",
                "0x59682f00",
                "0x77359400"
              ],
              [
                "0x3b9aca00",
                "0x6128a23a",
                "0x7f79dd55"
              ],
              [
                "0x1eae40bb",
                "0x6128a23a",
                "0x7d2b7500"
              ],
              [
                "0xec8ed6f",
                "0x65dfa187",
                "0x77359400"
              ],
              [
                "0x5f5e100",
                "0x4fe346fd",
                "0x7db5401a"
              ],
              [
                "0x3b9aca00",
                "0x7527935b",
                "0x7f8352a0"
              ],
              [
                "0x3019a029",
                "0x6d67f81b",
                "0x80151809"
              ],
              [
                "0x5f5e100",
                "0x59682f00",
                "0x7c65916f"
              ],
              [
                "0x5f5e100",
                "0x59682f00",
                "0x7ccfcdd3"
              ],
              [
                "0xdbe8842",
                "0x6d67f81b",
                "0x7c1af8d7"
              ]
            ]
          }
        }
    """
        let response = try JSONDecoder().decode(
            JSONRPCResponse<EthereumFeeHistory>.self,
            from: json.data(using: .utf8)!
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
