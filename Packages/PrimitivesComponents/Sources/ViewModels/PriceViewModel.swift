// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Style

public struct PriceViewModel {
    public let price: Price?

    private let currencyFormatter: CurrencyFormatter
    static let percentFormatter = CurrencyFormatter.percent

    public init(price: Price?, currencyCode: String) {
        self.price = price
        self.currencyFormatter = CurrencyFormatter(type: .abbreviated, currencyCode: currencyCode)
    }

    public var isPriceAvailable: Bool {
        price?.price != 0
    }

    public var priceAmountText: String {
        guard let price = price else { return "" }
        return currencyFormatter.string(price.price)
    }

    public var priceAmountColor: Color {
        guard let price = price else { return Colors.gray }
        if price.price == 0 {
            return Colors.grayLight
        } else if price.price >= 0 {
            return Colors.green
        }
        return Colors.red
    }

    private var priceChange: Double? {
        price?.priceChangePercentage24h ?? .none
    }

    public var priceChangeText: String {
        guard let priceChange = priceChange else { return "" }
        return Self.percentFormatter.string(priceChange)
    }

    public var priceChangeTextColor: Color {
        Self.priceChangeTextColor(value: priceChange)
    }

    public static func priceChangeTextColor(value: Double?) -> Color {
        if value == 0 {
            return Colors.grayLight
        } else if value ?? 0 >= 0 {
            return Colors.green
        }
        return Colors.red
    }

    public var priceChangeTextBackgroundColor: Color {
        if priceChange == 0 {
            return Colors.grayVeryLight
        } else if priceChange ?? 0 > 0 {
            return Colors.greenLight
        }
        return Colors.redLight
    }

    public func fiatAmountText(amount: Double) -> String {
        currencyFormatter.string(amount)
    }

    public func amountWithFiatText(amount: String, fiatAmount: Double) -> String {
        String(
            format: "%@ (%@)",
            amount,
            fiatAmountText(amount: fiatAmount)
        )
    }
}
