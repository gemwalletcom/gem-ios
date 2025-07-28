// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import Style
import SwiftUI
import PrimitivesComponents
import Store
import Preferences
import Localization

public struct PriceAlertItemViewModel: ListAssetItemViewable {
    public let data: PriceAlertData
    private let priceModel: PriceViewModel

    public init(data: PriceAlertData) {
        self.data = data
        switch data.priceAlert.type {
        case .auto:
            self.priceModel = PriceViewModel(price: data.price, currencyCode: Preferences.standard.currency)
        case .price, .pricePercentChange:
            self.priceModel = PriceViewModel(price: data.price, currencyCode: data.priceAlert.currency)
        }
    }

    public var name: String { data.asset.name }
    public var symbol: String? { data.asset.symbol }
    public var rightView: ListAssetItemRightView { .none }
    public var action: ((ListAssetItemAction) -> Void)?

    public var assetImage: AssetImage {
        AssetViewModel(asset: data.asset).assetImage
    }

    public var subtitleView: ListAssetItemSubtitleView {
        .price(
            price: prefixTextValue,
            priceChangePercentage24h: suffixTextValue
        )
    }
    
    // MARK: - Private
    
    private var prefixTextValue: TextValue {
        TextValue(
            text: prefixText,
            style: TextStyle(font: .footnote, color: Colors.gray)
        )
    }
    
    private var suffixTextValue: TextValue {
        TextValue(
            text: suffixText,
            style: TextStyle(font: .footnote, color: directionColor)
        )
    }
    
    private var prefixText: String {
        switch data.priceAlert.type {
        case .auto: priceModel.priceAmountText
        case .price: priceDirectionPrefix
        case .pricePercentChange: percentDirectionPrefix
        }
    }
    
    private var suffixText: String {
        switch data.priceAlert.type {
        case .auto: priceModel.priceChangeText
        case .price: priceModel.fiatAmountText(amount: data.priceAlert.price ?? .zero)
        case .pricePercentChange: "\(data.priceAlert.pricePercentChange ?? .zero)%"
        }
    }
    
    private var priceDirectionPrefix: String {
        switch data.priceAlert.priceDirection {
        case .up: Localized.PriceAlerts.Direction.over
        case .down: Localized.PriceAlerts.Direction.under
        case .none: .empty
        }
    }

    private var percentDirectionPrefix: String {
        switch data.priceAlert.priceDirection {
        case .up: Localized.PriceAlerts.Direction.increasesBy
        case .down: Localized.PriceAlerts.Direction.decreasesBy
        case .none: .empty
        }
    }
    
    private var directionColor: Color {
        switch data.priceAlert.priceDirection {
        case .up: Colors.green
        case .down: Colors.red
        case .none: priceModel.priceChangeTextColor
        }
    }
}
