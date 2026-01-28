// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Localization
import Components

struct TransactionNetworkViewModel: Sendable {
    private let chain: Chain

    init(chain: Chain) {
        self.chain = chain
    }
}

// MARK: - ItemModelProvidable

extension TransactionNetworkViewModel: ItemModelProvidable {
    var itemModel: TransactionItemModel {
        .network(
            title: Localized.Transfer.network,
            subtitle: chain.asset.name,
            image: AssetIdViewModel(assetId: chain.assetId).networkAssetImage
        )
    }
}
