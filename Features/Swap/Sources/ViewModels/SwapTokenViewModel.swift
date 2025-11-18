// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Localization
import PrimitivesComponents
import Formatters

enum SwapTokenViewType {
    case selected(AssetDataViewModel)
    case placeholder(currencyCode: String)
}

struct SwapTokenViewModel {
    private let type: SwapTokenViewType
    private let formatter = ValueFormatter(style: .medium)

    init(type: SwapTokenViewType) {
        self.type = type
    }

    var availableBalanceText: String? {
        switch type {
        case .selected(let model): Localized.Transfer.balance(model.availableBalanceText)
        case .placeholder: nil
        }
    }

    var assetImage: AssetImage? {
        switch type {
        case .selected(let model): model.assetImage
        case .placeholder: nil
        }
    }

    var actionTitle: String {
        switch type {
        case .selected(let model): model.asset.symbol
        case .placeholder: Localized.Assets.selectAsset
        }
    }

    func fiatBalance(amount: String) -> String {
        switch type {
        case .selected(let model):
            guard
                let value = try? formatter.inputNumber(from: amount, decimals: model.asset.decimals.asInt),
                let amount = try? formatter.double(from: value, decimals: model.asset.decimals.asInt),
                let price = model.priceViewModel.price
            else {
                return .empty
            }
            return model.priceViewModel.fiatAmountText(amount: price.price * amount)
        case .placeholder(let currencyCode):
            return CurrencyFormatter(currencyCode: currencyCode).string(.zero)
        }
    }
}
