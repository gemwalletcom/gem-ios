// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone
import Components
import BigInt
import SwiftUI
import PrimitivesComponents
import Style

public struct SwapProviderItem {
    public let asset: Asset
    public let swapQuote: SwapQuote
    public let priceViewModel: PriceViewModel
    public let formatter: ValueFormatter
    
    init(
        asset: Asset,
        swapQuote: SwapQuote,
        priceViewModel: PriceViewModel,
        formatter: ValueFormatter
    ) {
        self.asset = asset
        self.swapQuote = swapQuote
        self.priceViewModel = priceViewModel
        self.formatter = formatter
    }
    
    private var amount: String {
        formatter.string(swapQuote.toValueBigInt, decimals: asset.decimals.asInt)
    }

    private func fiatBalance() -> String {
        guard let value = try? formatter.inputNumber(from: amount, decimals: asset.decimals.asInt),
              let amount = try? formatter.double(from: value, decimals: asset.decimals.asInt),
              let price = priceViewModel.price
        else {
            return .empty
        }
        return priceViewModel.fiatAmountText(amount: price.price * amount)
    }
}

// MARK: - SimpleListItemViewable

extension SwapProviderItem: SimpleListItemViewable {
    public var title: String {
        swapQuote.data.provider.protocol
    }
    
    public var subtitle: String? {
        [amount, asset.symbol].joined(separator: " ")
    }
    
    public var image: Image {
        swapQuote.data.provider.image
    }
    
    public var subtitleExtra: String? {
        fiatBalance()
    }

    public var subtitleStyle: TextStyle {
        TextStyle(font: .callout, color: Colors.black)
    }
    
    public var subtitleStyleExtra: TextStyle {
        TextStyle(font: .footnote, color: Colors.gray)
    }
}

// MARK: - Identifiable

extension SwapProviderItem: Identifiable {
    public var id: String {
        [
            swapQuote.toValue,
            swapQuote.fromValue,
            swapQuote.data.provider.name
        ].joined(separator: "_")
    }
}

// MARK: - Hashable

extension SwapProviderItem: Hashable {
    public static func == (lhs: SwapProviderItem, rhs: SwapProviderItem) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
