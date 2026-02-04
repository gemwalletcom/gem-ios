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

    public var provider: String {
        position.provider.rawValue
    }

    public var id: String {
        provider
    }

    public var providerName: String {
        position.provider.displayName
    }

    public var hasBalance: Bool {
        vaultBalance > 0
    }

    public var vaultBalance: BigInt {
        BigInt(position.vaultBalanceValue) ?? .zero
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
