// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct WalletBalance: Sendable, Equatable {
    public let total: Double
    public let available: Double
    
    public init(total: Double, available: Double) {
        self.total = total
        self.available = available
    }
    
    public static let zero = WalletBalance(total: 0, available: 0)
}