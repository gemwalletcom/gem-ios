// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Style
import SwiftUI
import Formatters

public struct ListAssetItemViewModel: ListAssetItemViewable {
    let assetDataModel: AssetDataViewModel
    let type: AssetListType

    public let showBalancePrivacy: Binding<Bool>
    public var action: ((ListAssetItemAction) -> Void)?

    public init(
        showBalancePrivacy: Binding<Bool>,
        assetDataModel: AssetDataViewModel,
        type: AssetListType = .wallet,
        action: (((ListAssetItemAction)) -> Void)? = nil
    ) {
        self.showBalancePrivacy = showBalancePrivacy
        self.assetDataModel = assetDataModel
        self.type = type
        self.action = action
    }

    public init(
        showBalancePrivacy: Binding<Bool>,
        assetData: AssetData,
        formatter: ValueFormatter,
        currencyCode: String
    ) {
        let model = AssetDataViewModel(
            assetData: assetData,
            formatter: formatter,
            currencyCode: currencyCode
        )
        self.init(
            showBalancePrivacy: showBalancePrivacy,
            assetDataModel: model,
            type: .wallet,
            action: nil
        )
    }

    public var name: String {
        assetDataModel.name
    }

    public var symbol: String? {
        switch type {
        case .wallet, .view, .copy(.collection):
            return .none
        case .manage, .price, .copy(.asset):
            if name == assetDataModel.symbol {
                return .none
            }
            return assetDataModel.symbol
        }
    }

    public var subtitleView: ListAssetItemSubtitleView {
        switch type {
        case .wallet, .price:
            return .price(
                price: TextValue(
                    text: assetDataModel.priceAmountText,
                    style: TextStyle(font: .footnote, color: Colors.gray)
                ),
                priceChangePercentage24h: TextValue(
                    text: assetDataModel.priceChangeText,
                    style: TextStyle(font: .footnote, color: assetDataModel.priceChangeTextColor)
                )
            )
        case .manage, .view, .copy:
            switch assetDataModel.asset.id.type {
            case .native:
                return .none
            case .token:
                return .type(
                    TextValue(
                        text: assetDataModel.asset.chain.asset.name,
                        style: .calloutSecondary
                    )
                )
            }
        }
    }

    public var rightView: ListAssetItemRightView {
        switch type {
        case .wallet, .view:
            return .balance(
                balance: TextValue(
                    text: assetDataModel.totalBalanceTextWithSymbol,
                    style: TextStyle(font: .callout, color: assetDataModel.balanceTextColor, fontWeight: .semibold)
                ),
                totalFiat: TextValue(
                    text: assetDataModel.fiatBalanceText,
                    style: TextStyle(font: .footnote, color: Colors.gray)
                )
            )
        case .manage:
            return .toggle(assetDataModel.isEnabled)
        case .copy:
            return .copy
        case .price:
            return .none
        }
    }

    public var assetImage: AssetImage {
        return AssetViewModel(asset: assetDataModel.asset).assetImage
    }
}

