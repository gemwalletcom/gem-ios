// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

struct PerpetualPositionsInfo: FetchableRecord, Codable {
    var perpetual: PerpetualRecord
    var asset: AssetRecord
    var positions: [PerpetualPositionRecord]
}

extension PerpetualPositionsInfo {
    func mapToPerpetualPositionData() -> PerpetualPositionData? {
        guard let firstPosition = positions.first else { return nil }
        return PerpetualPositionData(
            perpetual: perpetual.mapToPerpetual(),
            asset: asset.mapToAsset(),
            position: firstPosition.mapToPerpetualPosition()
        )
    }
}
