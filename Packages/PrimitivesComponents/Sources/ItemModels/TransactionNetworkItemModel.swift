// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Style
import Localization
import Primitives

public struct TransactionNetworkItemModel: ListItemViewable {
    public let chain: Chain
    
    public init(chain: Chain) {
        self.chain = chain
    }
    
    public var listItemModel: ListItemType {
        .basic(
            title: Localized.Transfer.network,
            subtitle: chain.asset.name
        )
    }
    
    public var networkAssetImage: AssetImage {
        AssetIdViewModel(assetId: chain.assetId).networkAssetImage
    }
}