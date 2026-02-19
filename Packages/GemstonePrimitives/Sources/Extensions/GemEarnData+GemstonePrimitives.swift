// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemEarnData {
    public func map() -> Primitives.EarnData {
        Primitives.EarnData(
            contractAddress: contractAddress,
            callData: callData,
            approval: approval?.map(),
            gasLimit: gasLimit
        )
    }
}

extension Primitives.EarnData {
    public func map() -> GemEarnData {
        GemEarnData(
            contractAddress: contractAddress,
            callData: callData,
            approval: approval?.map(),
            gasLimit: gasLimit
        )
    }
}
