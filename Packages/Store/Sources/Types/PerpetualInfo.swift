// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

struct PerpetualInfo: FetchableRecord, Codable {
    var perpetual: PerpetualRecord
    var asset: AssetRecord
}

extension PerpetualInfo {
    func mapToPerpetualData() -> PerpetualData {
        return PerpetualData(
            perpetual: perpetual.mapToPerpetual(),
            asset: asset.mapToAsset(),
            metadata: PerpetualMetadata(isPinned: perpetual.isPinned)
        )
    }
}