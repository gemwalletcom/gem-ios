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
    private let priceModel: PriceViewModel

    public init(
        data: PriceAlertData,
        preferences: Preferences = .standard
    ) {
        self.data = data
        self.priceModel = PriceViewModel(price: data.price, currencyCode: preferences.currency)
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
        .price(
            price: TextValue(
                text: prefixText(),
                style: TextStyle(font: .footnote, color: Colors.gray)
            ),
            priceChangePercentage24h: TextValue(
                text: suffixText(),
                style: TextStyle(font: .footnote, color: directionColor())
            )
        )
    }
    
    // MARK: - Private methods
    
    private func prefixText() -> String {
        switch data.priceAlert.type {
        case .auto: priceModel.priceAmountText
        case .price: priceDirectionPrefix()
        case .pricePercent: percentDirectionPrefix()
        }
    }
    
    private func suffixText() -> String {
        switch data.priceAlert.type {
        case .auto: priceModel.priceChangeText
        case .price: priceModel.fiatAmountText(amount: data.priceAlert.price ?? .zero)
        case .pricePercent: "\(data.priceAlert.pricePercentChange ?? .zero)%"
        }
    }
    
    private func priceDirectionPrefix() -> String {
        switch data.priceAlert.priceDirection {
        case .up: "Exceeds"
        case .down: "Falls below"
        case .none: .empty
        }
    }

    private func percentDirectionPrefix() -> String {
        switch data.priceAlert.priceDirection {
        case .up: "Increases by"
        case .down: "Decreases by"
        case .none: .empty
        }
    }
    
    private func directionColor() -> Color {
        switch data.priceAlert.priceDirection {
        case .up: Colors.green
        case .down: Colors.red
        case .none: priceModel.priceChangeTextColor
        }
    }
}
