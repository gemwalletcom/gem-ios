// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone
import GemstonePrimitives
import BigInt

public protocol EthereumFeeCalculetable: Sendable {
    func basePriorityFees(
        chain: EVMChain,
        feeHistory: EthereumFeeHistory
    ) throws -> (base: BigInt, priority: [FeePriority: BigInt])
}

public struct EthereumFeeCalculator: Sendable {
    private let calculator: GemFeeCalculatorProtocol

    public init(calculator: GemFeeCalculatorProtocol = GemFeeCalculator()) {
        self.calculator = calculator
    }
}

// MARK: - EthereumFeeCalculetable

extension EthereumFeeCalculator: EthereumFeeCalculetable {
    public func basePriorityFees(
        chain: EVMChain,
        feeHistory: EthereumFeeHistory
    ) throws -> (base: BigInt, priority: [FeePriority: BigInt]) {

        guard let baseFeeHex = feeHistory.baseFeePerGas.last,
              let baseFee = try? BigInt.fromHex(baseFeeHex)
        else {
            throw AnyError("eth feeHistory: baseFeePerGas array might be empty or its last element is not a valid hex string")
        }

        let priorityFees = try calculator.caluclateBasePriorityFees(
            chain: chain.rawValue,
            history: GemEthereumFeeHistory(
                reward: feeHistory.reward,
                baseFeePerGas: feeHistory.baseFeePerGas,
                gasUsedRatio: feeHistory.gasUsedRatio,
                oldestBlock: feeHistory.oldestBlock
            )
        )
        
        let feesByPriority = FeePriority.allCases.reduce(into: [FeePriority: BigInt]()) { dict, priority in
            let fee = priorityFees.first { FeePriority($0.priority) == priority }.flatMap { BigInt($0.value) }
            dict[priority] = fee
        }

        return (baseFee, feesByPriority)
    }
}
