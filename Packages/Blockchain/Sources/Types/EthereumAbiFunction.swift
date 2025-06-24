// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import BigInt

public extension EthereumAbi {
    static func approve(spender: Data, value: BigInt) -> Data {
        let function = EthereumAbiFunction(name: "approve")
        function.addParamAddress(val: spender, isOutput: false)
        function.addParamUInt256(val: value.magnitude.serialize(), isOutput: false)
        return EthereumAbi.encode(fn: function)
    }
}
