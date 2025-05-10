// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletCore
import struct Gemstone.SignMessage
import class Gemstone.SignMessageDecoder
import enum Gemstone.MessagePreview

public struct SignMessageDecoderDefault {
    
    private let message: SignMessage
    
    public init(message: SignMessage) {
        self.message = message
    }
    
    public var decoder: SignMessageDecoder {
        SignMessageDecoder(message: message)
    }
    
    public var plainPreview: String {
        switch message.signType {
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
    
    public var preview: MessagePreview {
        get throws {
            try decoder.preview()
        }
    }
    
    public func getResult(from data: Data) -> String {
        decoder.getResult(data: data)
    }
}
