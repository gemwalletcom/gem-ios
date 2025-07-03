// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum TransactionMetadata: Codable, Sendable {
    case null
    case swap(TransactionSwapMetadata)
    case nft(TransactionNFTTransferMetadata)
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null:
            try container.encodeNil()
        case .swap(let value):
            try container.encode(value)
        case .nft(let value):
            try container.encode(value)
        }
    }

    //TODO: Stake
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        // decode TransactionSwapMetadata from the api and string from the db
        if let value = try? container.decode(TransactionSwapMetadata.self) {
            self = .swap(value)
            return
        } else if let value = try? container.decode(TransactionNFTTransferMetadata.self) {
            self = .nft(value)
        } else if let string = try? container.decode(String.self), let data = string.data(using: .utf8) {
            if let value = try? JSONDecoder().decode(TransactionSwapMetadata.self, from: data) {
                self = .swap(value)
                return
            } else if let value = try? JSONDecoder().decode(TransactionNFTTransferMetadata.self, from: data) {
                self = .nft(value)
                return
            }
        }
    
        self = .null
    }
}
