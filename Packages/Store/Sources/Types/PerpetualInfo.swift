// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

struct PerpetualInfo: FetchableRecord, Codable {
    var perpetual: PerpetualRecord
    var positions: [PerpetualPositionRecord]
}

extension PerpetualInfo {
    func mapToPerpetualPositionData() -> PerpetualPositionData {
        return PerpetualPositionData(
            perpetual: perpetual.mapToPerpetual(),
            positions: positions.map { $0.mapToPerpetualPosition() }
        )
    }
}
