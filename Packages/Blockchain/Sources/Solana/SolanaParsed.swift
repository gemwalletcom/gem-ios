// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct SolanaArrayData<T: Codable>: Codable {
    public let data: [T]
}

public struct SolanaParsedData<T: Codable>: Codable {
    public init(data: SolanaParsed<T>) {
        self.data = data
    }
    
    public let data: SolanaParsed<T>
}

public struct SolanaParsed<T: Codable>: Codable {
    public init(parsed: T) {
        self.parsed = parsed
    }
    
    public let parsed: T
}

public struct SolanaData<T: Codable>: Codable {
    public let data: T
}

public struct SolanaInfo<T: Codable>: Codable {
    public init(info: T) {
        self.info = info
    }

    public let info: T
}

public struct SolanaParsedSplTokenInfo: Codable {
    public init(decimals: Int32) {
        self.decimals = decimals
    }
    
    public let decimals: Int32
}

public struct SolanaTokenOwner: Codable {
    public let owner: String
}

typealias SolanaSplTokenInfo = SolanaValue<SolanaParsedData<SolanaInfo<SolanaParsedSplTokenInfo>>>
typealias SolanaMplRawData = SolanaValue<SolanaArrayData<String>>
typealias SolanaSplTokenOwner = SolanaValue<SolanaTokenOwner>

public let SplTokenProgram2022 = "TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb"
public let SplTokenProgram     = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"
