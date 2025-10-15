// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import PrimitivesComponents
import Components
import Swap
import Perpetuals

struct ConfirmDetailsViewModel {
    private let type: TransferDataType
    private let metadata: TransferDataMetadata?

    init(type: TransferDataType, metadata: TransferDataMetadata?) {
        self.type = type
        self.metadata = metadata
    }
}

// MARK: - ItemModelProvidable

extension ConfirmDetailsViewModel: ItemModelProvidable {
    var itemModel: ConfirmTransferItemModel {
        switch type {
        case let .swap(fromAsset, toAsset, swapData):
                .swapDetails(
                    SwapDetailsViewModel(
                        fromAssetPrice: AssetPriceValue(asset: fromAsset, price: metadata?.assetPrice),
                        toAssetPrice: AssetPriceValue(asset: toAsset, price: metadata?.assetPrices[toAsset.id]),
                        selectedQuote: swapData.quote
                    )
                )
        case let .perpetual(asset, perpetualType):
                .perpetualDetails(PerpetualDetailsViewModel(asset: asset, data: perpetualType.data))
        case .transfer,
                .deposit,
                .withdrawal,
                .transferNft,
                .tokenApprove,
                .stake,
                .account,
                .generic:
                .empty
        }
    }
}
