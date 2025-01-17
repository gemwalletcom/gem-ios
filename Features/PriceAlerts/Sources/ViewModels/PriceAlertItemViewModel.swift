// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import Style
import SwiftUI
import PrimitivesComponents
import Store
import Preferences

public struct PriceAlertItemViewModel: ListAssetItemViewable {
    public let data: PriceAlertData
    private let preferences: Preferences

    public init(
        data: PriceAlertData,
        preferences: Preferences = .standard
    ) {
        self.data = data
        self.preferences = preferences
    }

    public var showBalancePrivacy: Binding<Bool> { .constant(false) }
    public var name: String { data.asset.name }
    public var symbol: String? { data.asset.symbol }
    public var rightView: Components.ListAssetItemRightView { .none }
    public var action: ((Components.ListAssetItemAction) -> Void)?

    public var assetImage: Components.AssetImage {
        AssetViewModel(asset: data.asset).assetImage
    }

    public var subtitleView: Components.ListAssetItemSubtitleView {
        let priceModel = PriceViewModel(
            price: data.price,
            currencyCode: preferences.currency
        )
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
}
