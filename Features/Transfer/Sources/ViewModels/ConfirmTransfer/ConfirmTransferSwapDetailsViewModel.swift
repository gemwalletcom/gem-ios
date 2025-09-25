// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import PrimitivesComponents
import Components
import Swap

struct ConfirmTransferSwapDetailsViewModel {
    private let type: TransferDataType
    private let metadata: TransferDataMetadata?

    init(type: TransferDataType, metadata: TransferDataMetadata?) {
        self.type = type
        self.metadata = metadata
    }
}

// MARK: - ItemModelProvidable

extension ConfirmTransferSwapDetailsViewModel: ItemModelProvidable {
    var itemModel: ConfirmTransferItemModel {
        guard case let .swap(fromAsset, toAsset, swapData) = type else {
            return .empty
        }
        return .swapDetails(
            SwapDetailsViewModel(
                fromAssetPrice: AssetPriceValue(asset: fromAsset, price: metadata?.assetPrice),
                toAssetPrice: AssetPriceValue(asset: toAsset, price: metadata?.assetPrices[toAsset.id]),
                selectedQuote: swapData.quote
            )
        )
    }
}

