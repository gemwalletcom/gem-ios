// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Localization
import PrimitivesComponents

struct SwapTokenViewModel {
    private let model: AssetDataViewModel
    private let type: SelectAssetSwapType
    private let formatter = ValueFormatter(style: .medium)
    
    public init(
        model: AssetDataViewModel,
        type: SelectAssetSwapType
    ) {
        self.model = model
        self.type = type
    }
    
    var assetId: AssetId {
        model.asset.id
    }

    var availableBalanceText: String {
        Localized.Transfer.balance(model.availableBalanceText)
    }
    
    var assetImage: AssetImage {
        model.assetImage
    }
    
    var symbol: String {
        model.asset.symbol
    }
    
    func fiatBalance(amount: String) -> String {
        guard
            let value = try? formatter.inputNumber(from: amount, decimals: model.asset.decimals.asInt),
            let amount = try? formatter.double(from: value, decimals: model.asset.decimals.asInt),
            let price = model.priceViewModel.price
        else {
            return .empty
        }
        return model.priceViewModel.fiatAmountText(amount: price.price * amount)
    }
}
