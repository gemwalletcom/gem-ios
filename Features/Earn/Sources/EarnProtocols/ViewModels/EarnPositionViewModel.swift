// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Formatters
import Foundation
import Primitives
import PrimitivesComponents

public struct EarnPositionViewModel: Identifiable, Sendable {
    public let delegation: Delegation
    private let decimals: Int

    public init?(delegation: Delegation, decimals: Int) {
        self.delegation = delegation
        self.decimals = decimals
    }

    public var providerId: String {
        delegation.base.validatorId
    }

    public var id: String {
        delegation.base.delegationId
    }

    public var providerName: String {
        delegation.validator.name
    }

    public var hasBalance: Bool {
        balance > 0
    }

    public var balance: BigInt {
        BigInt(delegation.base.balance) ?? .zero
    }

    public var shares: BigInt {
        BigInt(delegation.base.shares) ?? .zero
    }

    public var assetBalanceFormatted: String {
        ValueFormatter(style: .medium).string(balance, decimals: decimals)
    }

    public var rewardsFormatted: String? {
        guard let rewards = BigInt(delegation.base.rewards), rewards > 0 else {
            return nil
        }
        return ValueFormatter(style: .medium).string(rewards, decimals: decimals)
    }

    public var apy: Double {
        delegation.validator.apr
    }

    public var apyFormatted: String {
        String(format: "%.2f%%", apy)
    }
}
