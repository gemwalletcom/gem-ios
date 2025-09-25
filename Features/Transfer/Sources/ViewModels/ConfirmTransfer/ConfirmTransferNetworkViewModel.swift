// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import PrimitivesComponents
import Components
import Localization

struct ConfirmTransferNetworkViewModel: ItemModelProvidable {
    private let type: TransferDataType

    init(type: TransferDataType) {
        self.type = type
    }
}

// MARK: - ItemModelProvidable

extension ConfirmTransferNetworkViewModel {
    var itemModel: ConfirmTransferItemModel {
        .network(
            ListItemModel(
                title: Localized.Transfer.network,
                subtitle: networkText,
                imageStyle: .list(assetImage: AssetIdViewModel(assetId: type.chain.asset.id).networkAssetImage))
        )
    }
}

// MARK: - Private

extension ConfirmTransferNetworkViewModel {
    private var networkText: String {
        let model = AssetViewModel(asset: type.asset)
        switch type {
        case .transfer, .deposit, .withdrawal:
            return model.networkFullName
        case .transferNft, .swap, .tokenApprove, .stake, .account, .generic, .perpetual:
            return model.networkName
        }
    }

}
