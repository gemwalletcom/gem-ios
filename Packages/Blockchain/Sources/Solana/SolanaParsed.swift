// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct SolanaArrayData<T: Codable & Sendable>: Codable, Sendable {
    public let data: [T]
}

public struct SolanaParsedData<T: Codable & Sendable>: Codable, Sendable {
    public init(data: SolanaParsed<T>) {
        self.data = data
    }
    
    public let data: SolanaParsed<T>
}

public struct SolanaParsed<T: Codable & Sendable>: Codable, Sendable {
    public init(parsed: T) {
        self.parsed = parsed
    }
    
    public let parsed: T
}

public struct SolanaData<T: Codable & Sendable>: Codable, Sendable {
    public let data: T
}

public struct SolanaInfo<T: Codable & Sendable>: Codable, Sendable {
    public init(info: T) {
        self.info = info
    }

    public let info: T
}

public struct SolanaParsedSplTokenInfo: Codable, Sendable {
    public init(decimals: Int32) {
        self.decimals = decimals
    }
    
    public let decimals: Int32
}

public struct SolanaTokenOwner: Codable, Sendable {
    public let owner: String
}

typealias SolanaSplTokenInfo = SolanaValue<SolanaParsedData<SolanaInfo<SolanaParsedSplTokenInfo>>>
typealias SolanaMplRawData = SolanaValue<SolanaArrayData<String>>
typealias SolanaSplTokenOwner = SolanaValue<SolanaTokenOwner>
