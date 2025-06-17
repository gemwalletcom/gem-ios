// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone
import GemstonePrimitives
import BigInt

public struct EthereumFeeCalculator: Sendable {
    private let calculator: GemFeeCalculatorProtocol

    public init(calculator: GemFeeCalculatorProtocol = GemFeeCalculator()) {
        self.calculator = calculator
    }
}

// MARK: - Public

extension EthereumFeeCalculator {
    public func basePriorityFees(
        feeHistory: EthereumFeeHistory,
        defaultMinPriorityFee: UInt64
    ) throws -> (base: BigInt, priority: [FeePriority: BigInt]) {

        guard let baseFeeHex = feeHistory.baseFeePerGas.last,
              let baseWei = try? BigInt.fromHex(baseFeeHex) else {
            throw AnyError("eth feeHistory: baseFeePerGas array is empty or invalid")
        }

        let minPriorityFee = try minPriorityFee(
            gasUsedRatios: feeHistory.gasUsedRatio,
            baseFeeHex: baseFeeHex,
            defaultMinPriorityFee: defaultMinPriorityFee
        )

        let priorityFees = try priorityFees(
            feeHistory: feeHistory,
            priorities: FeePriority.allCases,
            minPriorityFee: minPriorityFee
        )

        let feesByPriority = FeePriority.allCases.reduce(into: [FeePriority: BigInt]()) { dict, priority in
            let fee = priorityFees
                .first { FeePriority($0.priority) == priority }
                .flatMap { BigInt($0.value) } ?? BigInt(minPriorityFee)
            dict[priority] = fee
        }

        return (base: baseWei, priority: feesByPriority)
    }
}

// MARK: Private

extension EthereumFeeCalculator {
    private func minPriorityFee(
        gasUsedRatios: [Double],
        baseFeeHex: String,
        defaultMinPriorityFee: UInt64
    ) throws -> UInt64 {
        try calculator.calculateMinPriorityFee(
            gasUsedRatios: gasUsedRatios,
            baseFee: baseFeeHex,
            defaultMinPriorityFee: defaultMinPriorityFee
        )
    }

    private func priorityFees(
        feeHistory: EthereumFeeHistory,
        priorities: [FeePriority],
        minPriorityFee: UInt64
    ) throws -> [GemPriorityFeeRecord] {
        try calculator.calculatePriorityFees(
            feeHistory: GemEthereumFeeHistory(
                reward: feeHistory.reward,
                baseFeePerGas: feeHistory.baseFeePerGas,
                gasUsedRatio: feeHistory.gasUsedRatio,
                oldestBlock: feeHistory.oldestBlock
            ),
            priorities: priorities.map { GemFeePriority($0) },
            minPriorityFee: minPriorityFee
        )
    }
}
