// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Style

public struct PriceListItemViewModel {
    let title: String
    let model: PriceViewModel
    
    public init(
        title: String,
        model: PriceViewModel
    ) {
        self.title = title
        self.model = model
    }
    
    var showAmount: Bool {
        !priceAmount.text.isEmpty && !priceChangeView.text.isEmpty
    }
    
    var priceAmount: TextValue {
        TextValue(
            text: model.priceAmountText,
            style: .calloutSecondary
        )
    }
    
    var priceChangeView: TextValue {
        TextValue(
            text: model.priceChangeText,
            style: TextStyle(
                font: .callout,
                color: model.priceChangeTextColor,
                background: model.priceChangeTextBackgroundColor
            )
        )
    }
}
