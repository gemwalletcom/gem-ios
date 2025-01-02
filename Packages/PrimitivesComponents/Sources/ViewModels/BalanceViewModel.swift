// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Style

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
        formatter.string(balance.staked + balance.pending, decimals: asset.decimals.asInt, currency: asset.symbol)
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
}
