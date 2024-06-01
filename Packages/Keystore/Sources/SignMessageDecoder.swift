// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletCore

public struct SignMessageDecoder {
    
    private let message: SignMessage
    
    public init(message: SignMessage) {
        self.message = message
    }
    
    public var preview: String {
        switch message.type {
        case .sign,
            .eip191,
            .eip712:
            if let text = String(data: message.data, encoding: .utf8) {
                return text
            }
            return message.data.hexString
        case .base58:
            let string = String(decoding: message.data, as: UTF8.self)
            let data = Base58.decodeNoCheck(string: string) ?? Data()
            return String(data: data, encoding: .utf8) ?? ""
        }
    }
    
    public func getResult(from data: Data) -> String {
        switch message.type {
        case .sign,
            .eip191,
            .eip712:
            return data.hexString.append0x
        case .base58:
            return Base58.encodeNoCheck(data: data)
        }
    }
}
