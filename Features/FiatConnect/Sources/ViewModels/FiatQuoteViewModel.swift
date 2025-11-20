// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Style
import Components
import Formatters

public struct FiatQuoteViewModel: Sendable {
    let quote: FiatQuote
    let selectedQuote: FiatQuote?

    private let asset: Asset
    private let formatter: CurrencyFormatter

    public init(
        asset: Asset,
        quote: FiatQuote,
        selectedQuote: FiatQuote? = nil,
        formatter: CurrencyFormatter
    ) {
        self.asset = asset
        self.quote = quote
        self.selectedQuote = selectedQuote
        self.formatter = formatter
    }

    public var title: String {
        quote.provider.name
    }

    public var amountText: String {
        formatter.string(double: quote.cryptoAmount, symbol: asset.symbol)
    }

    public var rateText: String {
        let amount = quote.fiatAmount / quote.cryptoAmount
        return formatter.string(amount)
    }
    
    private var isSelected: Bool {
        selectedQuote?.provider == quote.provider
    }
}

extension FiatQuoteViewModel: Identifiable {
    public var id: String {
        "\(asset.id.identifier)\(quote.provider.name)\(quote.cryptoAmount)"
    }
}

// MARK: - SimpleListItemViewable

extension FiatQuoteViewModel: SimpleListItemViewable {
    public var assetImage: AssetImage {
        AssetImage(
            placeholder: Images.name(quote.provider.name.lowercased().replacing(" ", with: "_")),
            chainPlaceholder: isSelected ? Images.Wallets.selected : nil
        )
    }

    public var subtitle: String? { amountText }
}

// MARK: - Hashable

extension FiatQuoteViewModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
