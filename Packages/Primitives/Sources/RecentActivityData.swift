// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct RecentActivityData: Sendable {
    public let type: RecentActivityType
    public let assetId: AssetId
    public let toAssetId: AssetId?

    public init(type: RecentActivityType, assetId: AssetId, toAssetId: AssetId?) {
        self.type = type
        self.assetId = assetId
        self.toAssetId = toAssetId
    }
}
