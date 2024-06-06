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
}

struct AssetListViewModel: AssetListViewable {
    
    let assetDataModel: AssetDataViewModel
    let type: AssetListType
    var action: ((AssetListAction) -> Void)?
    
    init(
        assetDataModel: AssetDataViewModel,
        type: AssetListType = .wallet,
        action: (((AssetListAction)) -> Void)? = nil
    ) {
        self.assetDataModel = assetDataModel
        self.type = type
        self.action = action
    }
    
    var name: String {
        assetDataModel.name
    }
    
    var symbol: String? {
        switch type {
        case .wallet,
            .view:
            return .none
        case .manage,
            .copy:
            if name == assetDataModel.symbol {
                return .none
            }
            return assetDataModel.symbol
        }
    }
    
    var subtitleView: AssetListSubtitleView {
        switch type {
        case .wallet:
            return .price(
                price: TextValueView(
                    text: assetDataModel.priceAmountText,
                    style: TextStyle(font: .system(size: 14), color: Colors.gray)
                ),
                priceChangePercentage24h: TextValueView(
                    text: assetDataModel.priceChangeText,
                    style: TextStyle(font: .system(size: 14), color: assetDataModel.priceChangeTextColor)
                )
            )
        case .manage, .view, .copy:
            switch assetDataModel.asset.id.type {
            case .native:
                return .none
            case .token:
                return .type(
                    TextValueView(
                        text: assetDataModel.asset.chain.asset.name,
                        style: TextStyle(font: Font.system(.callout), color: .secondary)
                    )
                )
            }
        }
    }
    
    var rightView: AssetListRightView {
        switch type {
        case .wallet, .view:
            return .balance(
                balance: TextValueView(
                    text: assetDataModel.totalBalanceTextWithSymbol,
                    style: TextStyle(font: .system(size: 16, weight: .semibold), color: assetDataModel.balanceTextColor)
                ),
                totalFiat: TextValueView(
                    text: assetDataModel.fiatBalanceText,
                    style: TextStyle(font: .system(size: 14), color: Colors.gray)
                )
            )
        case .manage:
            return .toggle(assetDataModel.isEnabled)
        case .copy:
            return .copy
        }
    }
    
    public var assetImage: AssetImage {
        return AssetViewModel(asset: assetDataModel.asset).assetImage
    }
}

