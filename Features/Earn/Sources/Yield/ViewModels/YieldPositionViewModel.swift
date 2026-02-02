// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Formatters
import Foundation
import struct Gemstone.GemYieldPosition
import GemstonePrimitives

public struct YieldPositionViewModel: Sendable {
    public let position: GemYieldPosition
    public let decimals: Int

    public init(position: GemYieldPosition, decimals: Int) {
        self.position = position
        self.decimals = decimals
    }

    public var hasBalance: Bool {
        vaultBalance.map { $0 > 0 } ?? false
    }

    public var vaultBalance: BigInt? {
        position.vaultBalanceValue.flatMap { BigInt($0) }
    }

    public var assetBalanceFormatted: String {
        guard let balance = position.assetBalanceValue.flatMap({ BigInt($0) }) else {
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

    public var providerName: String {
        position.provider.displayName
    }
}
