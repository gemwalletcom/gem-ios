// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import PrimitivesComponents
import Components
import Swap

struct ConfirmSwapDetailsViewModel {
    private let type: TransferDataType
    private let metadata: TransferDataMetadata?

    init(type: TransferDataType, metadata: TransferDataMetadata?) {
        self.type = type
        self.metadata = metadata
    }

    var swapDetailsModel: SwapDetailsViewModel? {
        guard case let .swap(fromAsset, toAsset, swapData) = type else {
            return nil
        }
        return SwapDetailsViewModel(
            fromAssetPrice: AssetPriceValue(asset: fromAsset, price: metadata?.assetPrice),
            toAssetPrice: AssetPriceValue(asset: toAsset, price: metadata?.assetPrices[toAsset.id]),
            selectedQuote: swapData.quote
        )
    }
}

// MARK: - ItemModelProvidable

extension ConfirmSwapDetailsViewModel: ItemModelProvidable {
    var itemModel: ConfirmTransferItemModel {
        guard let swapDetailsModel = swapDetailsModel else {
            return .empty
        }
        return .swapDetails(swapDetailsModel)
    }
}
