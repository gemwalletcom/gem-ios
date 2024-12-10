// Copyright (c). Gem Wallet. All rights reserved.

import BigInt

public struct FeeRate: Identifiable, Equatable, Hashable, Sendable {
    public let priority: FeePriority
    public let gasPriceType: GasPriceType

    public init(priority: FeePriority, gasPriceType: GasPriceType) {
        self.priority = priority
        self.gasPriceType = gasPriceType
    }

    public var id: String { priority.id }
    public var baseFee: BigInt { gasPriceType.gasPrice }
    public var gasPrice: BigInt { baseFee + priorityFee }

    public var priorityFee: BigInt {
        switch gasPriceType {
        case .regular: .zero
        case .eip1559(_, let priority): priority
        }
    }
}
