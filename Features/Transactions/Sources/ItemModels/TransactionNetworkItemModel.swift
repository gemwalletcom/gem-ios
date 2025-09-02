// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Style
import Primitives
import PrimitivesComponents

public struct TransactionNetworkItemModel: ListItemViewable {
    public let title: String
    public let subtitle: String
    public let networkAssetImage: AssetImage
    
    public init(
        title: String,
        subtitle: String,
        networkAssetImage: AssetImage
    ) {
        self.title = title
        self.subtitle = subtitle
        self.networkAssetImage = networkAssetImage
    }
    
    public var listItemModel: ListItemType {
        .basic(
            title: title,
            subtitle: subtitle
        )
    }
}