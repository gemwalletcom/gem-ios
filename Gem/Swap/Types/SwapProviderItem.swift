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
    public let selectedProvider: Gemstone.SwapProvider?
    public let priceViewModel: PriceViewModel
    public let valueFormatter: ValueFormatter
    
    init(
        asset: Asset,
        swapQuote: SwapQuote,
        selectedProvider: Gemstone.SwapProvider?,
        priceViewModel: PriceViewModel,
        valueFormatter: ValueFormatter
    ) {
        self.asset = asset
        self.swapQuote = swapQuote
        self.selectedProvider = selectedProvider
        self.priceViewModel = priceViewModel
        self.valueFormatter = valueFormatter
    }
    
    private var amount: String {
        valueFormatter.string(swapQuote.toValueBigInt, decimals: asset.decimals.asInt)
    }
    
    private var isSelected: Bool {
        selectedProvider == swapQuote.data.provider.id
    }

    private func fiatBalance() -> String {
        guard let value = try? valueFormatter.inputNumber(from: amount, decimals: asset.decimals.asInt),
              let amount = try? valueFormatter.double(from: value, decimals: asset.decimals.asInt),
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
    
    public var titleStyle: TextStyle {
        TextStyle(font: .callout, color: Colors.black, fontWeight: .semibold)
    }
    
    public var subtitle: String? {
        [amount, asset.symbol].joined(separator: " ")
    }
    
    public var assetImage: AssetImage {
        AssetImage(
            placeholder: swapQuote.data.provider.image,
            chainPlaceholder: isSelected ? Images.Wallets.selected : nil
        )
    }
    
    public var subtitleExtra: String? {
        fiatBalance()
    }

    public var subtitleStyle: TextStyle {
        TextStyle(font: .callout, color: Colors.black, fontWeight: .semibold)
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
