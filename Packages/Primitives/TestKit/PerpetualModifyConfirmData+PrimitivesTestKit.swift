// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension PerpetualModifyConfirmData {
    static func mock(
        baseAsset: Asset = .mock(),
        assetIndex: Int32 = 0,
        modifyTypes: [PerpetualModifyPositionType] = [],
        takeProfitOrderId: UInt64? = nil,
        stopLossOrderId: UInt64? = nil
    ) -> PerpetualModifyConfirmData {
        PerpetualModifyConfirmData(
            baseAsset: baseAsset,
            assetIndex: assetIndex,
            modifyTypes: modifyTypes,
            takeProfitOrderId: takeProfitOrderId,
            stopLossOrderId: stopLossOrderId
        )
    }
}
