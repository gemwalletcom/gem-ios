import Foundation
import Primitives
import Components
import Style
import SwiftUI

enum AssetListType {
    case wallet
    case manage
    case view
    case copy
    case price
}

struct ListAssetItemViewModel: ListAssetItemViewable {

    let assetDataModel: AssetDataViewModel
    let type: AssetListType
    var action: ((ListAssetItemAction) -> Void)?

    init(
        assetDataModel: AssetDataViewModel,
        type: AssetListType = .wallet,
        action: (((ListAssetItemAction)) -> Void)? = nil
    ) {
        self.assetDataModel = assetDataModel
        self.type = type
        self.action = action
    }

    init(assetData: AssetData, formatter: ValueFormatter) {
        let model = AssetDataViewModel(assetData: assetData, formatter: formatter)
        self.init(assetDataModel: model, type: .wallet, action: nil)
    }

    var name: String {
        assetDataModel.name
    }
    
    var symbol: String? {
        switch type {
        case .wallet,
            .view,
            .price:
            return .none
        case .manage,
            .copy:
            if name == assetDataModel.symbol {
                return .none
            }
            return assetDataModel.symbol
        }
    }
    
    var subtitleView: ListAssetItemSubtitleView {
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
    
    var rightView: ListAssetItemRightView {
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

