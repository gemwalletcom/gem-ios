// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

public struct EthereumCallDecoder: Sendable {
    private let decoder = Gemstone.EthereumDecoder()
    
    public init() {}
    
    public func decode(data: String) -> DecodedCall? {
        guard let decoded = try? decoder.decodeCall(calldata: data, abi: nil) else { return nil }

        let method = ContractMethod(rawValue: decoded.function)
        
        let recipient = method?.recipientField.flatMap { field in
            decoded.params.first { $0.name == field }?.value
        }
        
        let amount = method?.amountField.flatMap { field in
            decoded.params.first { $0.name == field }?.value  
        }
        
        return DecodedCall(
            method: method,
            recipient: recipient,
            amount: amount
        )
    }
}
