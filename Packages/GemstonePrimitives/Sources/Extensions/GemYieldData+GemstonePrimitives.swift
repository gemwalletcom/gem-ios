// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.YieldData {
    public func map() -> Primitives.YieldData {
        Primitives.YieldData(
            provider: provider,
            contractAddress: contractAddress,
            callData: callData,
            approval: approval?.map(),
            gasLimit: gasLimit
        )
    }
}

extension Primitives.YieldData {
    public func map() -> Gemstone.YieldData {
        Gemstone.YieldData(
            provider: provider,
            contractAddress: contractAddress,
            callData: callData,
            approval: approval?.map(),
            gasLimit: gasLimit
        )
    }
}
