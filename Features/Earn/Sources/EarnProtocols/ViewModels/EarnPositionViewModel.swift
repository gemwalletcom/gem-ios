// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Formatters
import Foundation
import Primitives
import PrimitivesComponents

public struct EarnPositionViewModel: Identifiable, Sendable {
    private let position: EarnPosition
    private let decimals: Int

    public init?(position: EarnPosition, decimals: Int) {
        self.position = position
        self.decimals = decimals
    }

    public var providerId: String {
        position.base.providerId
    }

    public var id: String {
        position.base.positionId
    }

    public var providerName: String {
        position.provider.name
    }

    public var hasBalance: Bool {
        balance > 0
    }

    public var balance: BigInt {
        BigInt(position.base.balance) ?? .zero
    }

    public var shares: BigInt {
        BigInt(position.base.shares) ?? .zero
    }

    public var assetBalanceFormatted: String {
        ValueFormatter(style: .medium).string(balance, decimals: decimals)
    }

    public var rewardsFormatted: String? {
        guard let rewards = BigInt(position.base.rewards), rewards > 0 else {
            return nil
        }
        return ValueFormatter(style: .medium).string(rewards, decimals: decimals)
    }

    public var apy: Double {
        position.provider.apy
    }

    public var apyFormatted: String {
        String(format: "%.2f%%", apy)
    }
}
