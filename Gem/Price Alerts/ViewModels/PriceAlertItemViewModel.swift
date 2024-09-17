// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import Style

struct PriceAlertItemViewModel: ListAssetItemViewable {

    let data: PriceAlertData

    var name: String { data.asset.name }

    var symbol: String? { data.asset.symbol }

    var assetImage: Components.AssetImage {
        AssetViewModel(asset: data.asset).assetImage
    }

    var subtitleView: Components.ListAssetItemSubtitleView {
        let priceModel = PriceViewModel(price: data.price)
        return .price(
            price: TextValue(
                text: priceModel.priceAmountText,
                style: TextStyle(font: .footnote, color: Colors.gray)
            ),
            priceChangePercentage24h: TextValue(
                text: priceModel.priceChangeText,
                style: TextStyle(font: .footnote, color: priceModel.priceChangeTextColor)
            )
        )
    }

    var rightView: Components.ListAssetItemRightView {
        .none
    }

    var action: ((Components.ListAssetItemAction) -> Void)?
}
