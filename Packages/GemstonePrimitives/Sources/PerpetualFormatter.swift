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

    public func minimumOrderUsdAmount(price: Double, decimals: Int32, leverage: UInt8) -> UInt64 {
        perpetual.minimumOrderUsdAmount(provider: provider.map(), price: price, decimals: decimals, leverage: leverage)
    }

    public func formatPrice(_ price: Double, decimals: Int32) -> String {
        perpetual.formatPrice(provider: provider.map(), price: price, decimals: decimals)
    }

    public func formatSize(_ size: Double, decimals: Int32) -> String {
        perpetual.formatSize(provider: provider.map(), size: size, decimals: decimals)
    }

    public func formatInputPrice(_ price: Double, decimals: Int32, locale: Locale = .current) -> String {
        let formatted = perpetual.formatPrice(provider: provider.map(), price: price, decimals: decimals)
        let decimalSeparator = locale.decimalSeparator ?? "."
        guard decimalSeparator != "." else {
            return formatted
        }
        return formatted.replacingOccurrences(of: ".", with: decimalSeparator)
    }
}
