// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import Style
import SwiftUI
import PrimitivesComponents
import Formatters

public struct PerpetualItemViewModel: ListAssetItemViewable {
    
    public let model: PerpetualViewModel
    
    public init(
        model: PerpetualViewModel
    ) {
        self.model = model
    }

    public var name: String { model.name }
    public var symbol: String? { .none }
    public var action: ((ListAssetItemAction) -> Void)?
    
    public var assetImage: AssetImage {
        model.assetImage
    }
    
    public var subtitleView: ListAssetItemSubtitleView {
        .price(
            price: TextValue(
                text: model.priceText,
                style: TextStyle(font: .footnote, color: Colors.gray)
            ),
            priceChangePercentage24h: TextValue(
                text: model.priceChangeText,
                style: TextStyle(font: .footnote, color: model.priceChangeTextColor)
            )
        )
    }
    
    public var rightView: ListAssetItemRightView {
        .balance(
            balance: TextValue(
                text: model.volumeText,
                style: TextStyle(font: .body, color: .primary, fontWeight: .semibold)
            ),
            totalFiat: TextValue(
                text: "",
                style: TextStyle(font: .footnote, color: .secondary)
            )
        )
    }
}
