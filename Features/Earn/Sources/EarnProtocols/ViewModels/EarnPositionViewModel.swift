// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Formatters
import Foundation
import Gemstone
import GemstonePrimitives
import Primitives

public struct EarnPositionViewModel: Identifiable, Sendable {
    private let position: EarnPosition
    private let yieldData: YieldPositionData
    private let decimals: Int

    public init?(position: EarnPosition, decimals: Int) {
        guard let yieldData = position.type.yieldData else { return nil }
        self.position = position
        self.yieldData = yieldData
        self.decimals = decimals
    }

    public var provider: String {
        yieldData.provider
    }

    public var id: String {
        provider
    }

    public var providerName: String {
        GemYieldProvider.allCases.first { $0.name == yieldData.provider }?.displayName ?? yieldData.provider
    }

    public var hasBalance: Bool {
        vaultBalance.map { $0 > 0 } ?? false
    }

    public var vaultBalance: BigInt? {
        yieldData.vaultBalanceValue.flatMap { BigInt($0) }
    }

    public var assetBalanceFormatted: String {
        guard let balance = BigInt(position.balance) else {
            return "0"
        }
        return ValueFormatter(style: .medium).string(balance, decimals: decimals)
    }

    public var rewardsFormatted: String? {
        guard let rewards = position.rewards.flatMap({ BigInt($0) }), rewards > 0 else {
            return nil
        }
        return ValueFormatter(style: .medium).string(rewards, decimals: decimals)
    }
}
