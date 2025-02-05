// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import WalletCore

public struct EthereumSwapService {
    let chain: EVMChain
    let provider: Provider<EthereumTarget>
    
    public init(
        chain: EVMChain,
        provider: Provider<EthereumTarget>
    ) {
        self.chain = chain
        self.provider = provider
    }
    
    public func getAllowance(contract: String, owner: String, spender: String) async throws -> BigInt {
        let function = EthereumAbiFunction(name: "allowance")
        function.addParamAddress(val: Data(hexString: owner.remove0x)!, isOutput: false)
        function.addParamAddress(val: Data(hexString: spender.remove0x)!, isOutput: false)
        let data = EthereumAbi.encode(fn: function)
        
        let params = [
            "to": contract,
            "data": "0x" + data.hexString,
        ]
        return try await self.provider.request(.call(params))
            .map(as: JSONRPCResponse<BigIntable>.self).result.value
    }
}
