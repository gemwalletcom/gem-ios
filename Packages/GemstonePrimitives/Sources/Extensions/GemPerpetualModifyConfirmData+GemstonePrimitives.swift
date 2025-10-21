// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.PerpetualModifyConfirmData {
    public func map() throws -> Primitives.PerpetualModifyConfirmData {
        Primitives.PerpetualModifyConfirmData(
            baseAsset: try baseAsset.map(),
            assetIndex: assetIndex,
            modifyType: try modifyType.map()
        )
    }
}

extension Primitives.PerpetualModifyConfirmData {
    public func map() -> Gemstone.PerpetualModifyConfirmData {
        Gemstone.PerpetualModifyConfirmData(
            baseAsset: baseAsset.map(),
            assetIndex: assetIndex,
            modifyType: modifyType.map()
        )
    }
}
