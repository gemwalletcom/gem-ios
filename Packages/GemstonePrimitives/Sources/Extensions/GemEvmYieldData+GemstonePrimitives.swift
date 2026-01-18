// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemEvmYieldData {
    public func map() -> EvmYieldData {
        EvmYieldData(
            contractAddress: contractAddress,
            callData: callData,
            approval: approval?.map(),
            gasLimit: gasLimit
        )
    }
}

extension EvmYieldData {
    public func map() -> GemEvmYieldData {
        GemEvmYieldData(
            contractAddress: contractAddress,
            callData: callData,
            approval: approval?.map(),
            gasLimit: gasLimit
        )
    }
}
