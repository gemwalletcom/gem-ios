// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct Payment: Equatable {
    let address: String
    let amount: String?
    let memo: String?
}

struct PaymentURLDecoder {
    func decode(_ string: String) throws -> Payment {
        let chunks = string.split(separator: ":")
        
        // has more than an address
        if chunks.count == 2 {
            //TODO: Check prefix for bitcoin and other chains
            //let _prefix = chunks[0]
            let path = chunks[1]
            let pathChunks = path.split(separator: "?")
            
            if pathChunks.count == 1 {
                return Payment(address: String(path), amount: .none, memo: .none)
            } else if pathChunks.count == 2 {
                // BIP21 parsing
                let address = String(pathChunks[0])
                let query = String(pathChunks[1])
                let params = decodeQueryString(query)
                let amount = params["amount"]
                let memo = params["memo"]
                
                return Payment(address: address, amount: amount, memo: memo)
            } else {
                throw AnyError("BIP21 format is incorrect")
            }
        }
        return Payment(address: string, amount: .none, memo: .none)
    }
    
    func decodeQueryString(_ queryString: String) -> [String: String] {
        return Dictionary(
            uniqueKeysWithValues: queryString
                .split(separator: "&")
                .compactMap { pair in
                    let components = pair.split(separator: "=")
                    return components.count == 2 ? (String(components[0]), String(components[1])) : nil
                }
        )
    }
}
