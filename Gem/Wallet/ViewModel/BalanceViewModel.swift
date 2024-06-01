import Foundation
import SwiftUI
import Primitives
import Style

enum BalanceStyle {
    case short
    case medium
    case full
}

struct BalanceViewModel {
    private let asset: Asset
    private let balance: Balance
    private let formatter: ValueFormatter

    init(
        asset: Asset,
        balance: Balance,
        formatter: ValueFormatter
    ) {
        self.asset = asset
        self.balance = balance
        self.formatter = formatter
    }
    
    var balanceAmount: Double {
        do {
            return try ValueFormatter(style: .full).double(from: balance.total, decimals: asset.decimals.asInt)
        } catch {
            return 0
        }
    }
    
    var balanceText: String {
        guard !balance.total.isZero else {
            return .zero
        }
        return formatter.string(balance.total, decimals: asset.decimals.asInt)
    }
    
    var availableBalanceText: String {
        guard !balance.available.isZero else {
            return .zero
        }
        return formatter.string(balance.available, decimals: asset.decimals.asInt)
    }
    
    var totalBalanceTextWithSymbol: String {
        formatter.string(balance.total, decimals: asset.decimals.asInt, currency: asset.symbol)
    }
    
    var availableBalanceTextWithSymbol: String {
        formatter.string(balance.available, decimals: asset.decimals.asInt, currency: asset.symbol)
    }
    
    var stakingBalanceTextWithSymbol: String {
        formatter.string(balance.staked + balance.pending, decimals: asset.decimals.asInt, currency: asset.symbol)
    }
    
    var hasReservedBalance: Bool {
        !balance.reserved.isZero
    }
    
    var reservedBalanceTextWithSymbol: String {
        formatter.string(balance.reserved, decimals: asset.decimals.asInt, currency: asset.symbol)
    }
    
    var balanceTextColor: Color {
        guard !balance.total.isZero else {
            return Colors.gray
        }
        return  Colors.black
    }
}
