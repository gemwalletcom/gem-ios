// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone

public struct PerpetualFormatter {
    private let perpetual = Gemstone.Perpetual()

    public init() {}

    public func minimumOrderUsdAmount(provider: Primitives.PerpetualProvider, price: Double, decimals: Int, leverage: UInt8) -> UInt64 {
        perpetual.minimumOrderUsdAmount(provider: provider.map(), price: price, decimals: Int32(decimals), leverage: leverage)
    }

    public func formatPrice(provider: Primitives.PerpetualProvider, _ price: Double, decimals: Int) -> String {
        perpetual.formatPrice(provider: provider.map(), price: price, decimals: Int32(decimals))
    }

    public func formatSize(provider: Primitives.PerpetualProvider, _ size: Double, decimals: Int) -> String {
        perpetual.formatSize(provider: provider.map(), size: size, decimals: Int32(decimals))
    }

    public func formatInputPrice(provider: Primitives.PerpetualProvider, _ price: Double, locale: Locale = Locale.current, decimals: Int) -> String {
        let formattedPrice = perpetual.formatPrice(provider: provider.map(), price: price, decimals: Int32(decimals))

        guard locale.decimalSeparator == "," else {
            return formattedPrice
        }

        return formattedPrice.replacingOccurrences(of: ".", with: ",")
    }
}
