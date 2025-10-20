// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct TransactionId: Equatable, Hashable, Sendable {
    public let chain: Chain
    public let hash: String

    public init(chain: Chain, hash: String) {
        self.chain = chain
        self.hash = hash
    }
    
    public init(id: String) throws {
        if let (chain, hash) = AssetId.getData(id: id), let hash {
            self.init(chain: chain, hash: hash)
        } else {
            throw AnyError("invalid transaction id: \(id)")
        }
    }
    
    public var identifier: String {
        chain.rawValue + "_" + hash
    }
}

extension TransactionId: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let id = try container.decode(String.self)
        self = try TransactionId.init(id: id)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(identifier)
    }
}
