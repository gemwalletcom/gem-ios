// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

struct PositionInfo: Decodable, FetchableRecord {
    var position: PerpetualPositionRecord
    var perpetual: PerpetualRecord
}

extension PositionInfo {
    func mapToPerpetualPosition() throws -> PerpetualPosition {
        return position.mapToPerpetualPosition()
    }
    
    func mapToPerpetualPositionData() throws -> PerpetualPositionData {
        return PerpetualPositionData(
            position: position.mapToPerpetualPosition(),
            perpetual: try perpetual.mapToPerpetual()
        )
    }
}
