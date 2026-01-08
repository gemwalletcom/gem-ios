// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

struct RecentAssetRecordInfo: FetchableRecord, Decodable {
    var asset: AssetRecord
    var maxCreatedAt: Date
}

extension RecentAssetRecordInfo {
    var mapToRecentAsset: RecentAsset {
        RecentAsset(
            asset: asset.mapToAsset(),
            createdAt: maxCreatedAt
        )
    }
}
