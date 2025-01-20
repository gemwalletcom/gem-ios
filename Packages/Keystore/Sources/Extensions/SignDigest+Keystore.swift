// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletCore

extension SignMessage {
    public var hash: Data {
        switch type {
        case .sign:
            return data
        case .eip191:
            let prefix = "\u{19}Ethereum Signed Message:\n\(data.count)".data(using: .utf8)!
            let hash = prefix + data
            return Hash.keccak256(data: hash)
        case .eip712:
            guard let jsonString = String(data: data, encoding: .utf8) else {
                return Data()
            }
            return EthereumAbi.encodeTyped(messageJson: jsonString)
        case .base58:
            guard
                let string = String(data: data, encoding: .utf8),
                let data = Base58.decodeNoCheck(string: string)
            else {
                return Data()
            }
            return data
        }
    }
}
