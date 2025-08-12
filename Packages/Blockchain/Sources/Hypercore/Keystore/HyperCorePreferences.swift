// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct HyperCorePreferences: Equatable, Sendable {
    public let address: String
    public let privateKey: Data
    
    public init(address: String, privateKey: Data) {
        self.address = address
        self.privateKey = privateKey
    }
}
