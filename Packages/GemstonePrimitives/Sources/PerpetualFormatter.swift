// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone

public struct PerpetualFormatter {
    private let perpetual = Gemstone.Perpetual()
    private let provider: Primitives.PerpetualProvider

    public init(provider: Primitives.PerpetualProvider) {
        self.provider = provider
    }

    public func minimumOrderUsdAmount(price: Double, decimals: Int, leverage: UInt8) -> UInt64 {
        perpetual.minimumOrderUsdAmount(provider: provider.map(), price: price, decimals: decimals.asInt32, leverage: leverage)
    }

    public func formatPrice(_ price: Double, decimals: Int) -> String {
        perpetual.formatPrice(provider: provider.map(), price: price, decimals: decimals.asInt32)
    }

    public func formatSize(_ size: Double, decimals: Int) -> String {
        perpetual.formatSize(provider: provider.map(), size: size, decimals: decimals.asInt32)
    }

    public func formatInputPrice(_ price: Double, locale: Locale = Locale.current, decimals: Int) -> String {
        let formattedPrice = perpetual.formatPrice(provider: provider.map(), price: price, decimals: decimals.asInt32)

        guard locale.decimalSeparator == "," else {
            return formattedPrice
        }

        return formattedPrice.replacingOccurrences(of: ".", with: ",")
    }
}
