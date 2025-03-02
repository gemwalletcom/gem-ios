// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone
import Components
import BigInt
import SwiftUI

public struct SwapProviderItem {
    public let asset: Asset
    public let swapQuote: SwapQuote
    public let formatter = ValueFormatter(style: .short)
    
    private var amount: String {
        let value = (try? BigInt.from(string: swapQuote.toValue)) ?? .zero
        return formatter.string(value, decimals: asset.decimals.asInt)
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
        swapQuote.data.provider.id.image
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
