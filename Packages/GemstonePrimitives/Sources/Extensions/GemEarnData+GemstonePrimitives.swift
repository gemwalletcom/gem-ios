// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.EarnData {
    public func map() -> Primitives.EarnData {
        Primitives.EarnData(
            provider: provider,
            contractAddress: contractAddress,
            callData: callData,
            approval: approval?.map(),
            gasLimit: gasLimit
        )
    }
}

extension Primitives.EarnData {
    public func map() -> Gemstone.EarnData {
        Gemstone.EarnData(
            provider: provider,
            contractAddress: contractAddress,
            callData: callData,
            approval: approval?.map(),
            gasLimit: gasLimit
        )
    }
}
