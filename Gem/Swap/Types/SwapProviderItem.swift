// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone
import Components
import BigInt
import SwiftUI

struct SwapProviderItem {
    let asset: Asset
    let swapQuote: SwapQuote
    let formatter = ValueFormatter(style: .full)
    
    private var rateText: String {
        [amount, asset.symbol].joined(separator: " ")
    }
    
    private var amount: String {
        let value = (try? BigInt.from(string: swapQuote.toValue)) ?? .zero
        return formatter.string(value, decimals: asset.decimals.asInt)
    }
}

extension SwapProviderItem: SimpleListItemViewable {
    var title: String {
        swapQuote.data.provider.name
    }
    
    var subtitle: String? {
        rateText
    }
    
    var image: Image {
        swapQuote.data.provider.image
    }
}

extension SwapProviderItem: Identifiable {
    var id: String {
        [swapQuote.toValue, swapQuote.fromValue, swapQuote.data.provider.name].joined(separator: ":")
    }
}
