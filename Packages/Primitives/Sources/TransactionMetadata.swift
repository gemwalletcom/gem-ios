// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum TransactionMetadata: Codable, Sendable {
    case null
    case swap(TransactionSwapMetadata)
    case nft(TransactionNFTTransferMetadata)
    case perpetual(TransactionPerpetualMetadata)
    case generic([String: String])

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null:
            try container.encodeNil()
        case .swap(let value):
            try container.encode(value)
        case .nft(let value):
            try container.encode(value)
        case .perpetual(let value):
            try container.encode(value)
        case .generic(let value):
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
            return
        } else if let value = try? container.decode(TransactionPerpetualMetadata.self) {
            self = .perpetual(value)
            return
        } else if let value = try? container.decode([String: String].self) {
            self = .generic(value)
            return
        } else if let string = try? container.decode(String.self), let data = string.data(using: .utf8) {
            if let value = try? JSONDecoder().decode(TransactionSwapMetadata.self, from: data) {
                self = .swap(value)
                return
            } else if let value = try? JSONDecoder().decode(TransactionNFTTransferMetadata.self, from: data) {
                self = .nft(value)
                return
            } else if let value = try? JSONDecoder().decode(TransactionPerpetualMetadata.self, from: data) {
                self = .perpetual(value)
                return
            } else if let value = try? JSONDecoder().decode([String: String].self, from: data) {
                self = .generic(value)
                return
            }
        }

        self = .null
    }

    public static func generic<T: Encodable>(from value: T) -> TransactionMetadata {
        guard let data = try? JSONEncoder().encode(value),
              let dict = try? JSONDecoder().decode([String: String].self, from: data)
        else {
            return .null
        }
        return .generic(dict)
    }

    public var resourceType: Resource? {
        guard case .generic(let dict) = self else { return nil }
        return try? dict.mapTo(TransactionResourceTypeMetadata.self).resourceType
    }

    public var walletConnectOutputAction: TransferDataOutputAction? {
        guard case .generic(let dict) = self else { return nil }
        return try? dict.mapTo(TransactionWalletConnectMetadata.self).outputAction
    }
}
