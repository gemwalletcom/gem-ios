// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Style
import Formatters
import BigInt

public struct BalanceViewModel: Sendable {
    private static let fullFormatter = ValueFormatter(style: .full)

    private let asset: Asset
    private let balance: Balance
    private let formatter: ValueFormatter

    public init(
        asset: Asset,
        balance: Balance,
        formatter: ValueFormatter
    ) {
        self.asset = asset
        self.balance = balance
        self.formatter = formatter
    }

    public var balanceAmount: Double {
        do {
            return try Self.fullFormatter.double(from: balance.total, decimals: asset.decimals.asInt)
        } catch {
            return .zero
        }
    }

    public var availableBalanceAmount: Double {
        do {
            return try Self.fullFormatter.double(from: balance.available, decimals: asset.decimals.asInt)
        } catch {
            return .zero
        }
    }

    public var balanceText: String {
        guard !balance.total.isZero else {
            return .zero
        }
        return formatter.string(balance.total, decimals: asset.decimals.asInt)
    }

    public var availableBalanceText: String {
        guard !balance.available.isZero else {
            return .zero
        }
        return formatter.string(balance.available, decimals: asset.decimals.asInt)
    }

    public var totalBalanceTextWithSymbol: String {
        formatter.string(balance.total, decimals: asset.decimals.asInt, currency: asset.symbol)
    }

    public var availableBalanceTextWithSymbol: String {
        formatter.string(balance.available, decimals: asset.decimals.asInt, currency: asset.symbol)
    }

    public var stakingBalanceTextWithSymbol: String {
        let amount = switch StakeChain(rawValue: asset.chain.rawValue) {
        case .celestia, .cosmos, .hyperCore, .injective, .osmosis, .sei, .smartChain, .solana, .sui, .none: balance.staked + balance.pending
        case .tron: balance.frozen + balance.locked + balance.pending
        }
        return formatter.string(amount, decimals: asset.decimals.asInt, currency: asset.symbol)
    }

    public var hasStakingResources: Bool {
        switch StakeChain(rawValue: asset.chain.rawValue) {
        case .celestia, .cosmos, .hyperCore, .injective, .osmosis, .sei, .smartChain, .solana, .sui, .none: false
        case .tron: !balance.frozen.isZero || !balance.locked.isZero
        }
    }

    public var hasReservedBalance: Bool {
        !balance.reserved.isZero
    }

    public var reservedBalanceTextWithSymbol: String {
        formatter.string(balance.reserved, decimals: asset.decimals.asInt, currency: asset.symbol)
    }

    public var balanceTextColor: Color {
        guard !balance.total.isZero else {
            return Colors.gray
        }
        return Colors.black
    }

    public var energyText: String {
        guard let metadata = balance.metadata else { return "" }
        return "\(metadata.energyAvailable) / \(metadata.energyTotal)"
    }

    public var bandwidthText: String {
        guard let metadata = balance.metadata else { return "" }
        return "\(metadata.bandwidthAvailable) / \(metadata.bandwidthTotal)"
    }
}
