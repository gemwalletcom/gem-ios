// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.PerpetualModifyConfirmData {
    public func map() throws -> Primitives.PerpetualModifyConfirmData {
        Primitives.PerpetualModifyConfirmData(
            baseAsset: try baseAsset.map(),
            assetIndex: assetIndex,
            modifyTypes: try modifyTypes.map { try $0.map() },
            takeProfitOrderId: takeProfitOrderId,
            stopLossOrderId: stopLossOrderId
        )
    }
}

extension Primitives.PerpetualModifyConfirmData {
    public func map() -> Gemstone.PerpetualModifyConfirmData {
        Gemstone.PerpetualModifyConfirmData(
            baseAsset: baseAsset.map(),
            assetIndex: assetIndex,
            modifyTypes: modifyTypes.map { $0.map() },
            takeProfitOrderId: takeProfitOrderId,
            stopLossOrderId: stopLossOrderId
        )
    }
}
