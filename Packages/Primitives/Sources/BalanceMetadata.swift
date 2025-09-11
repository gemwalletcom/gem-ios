// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct BalanceMetadata: Codable, Equatable, Hashable, Sendable {
    public let energyAvailable: UInt64
    public let energyTotal: UInt64
    public let bandwidthAvailable: UInt64
    public let bandwidthTotal: UInt64

    public init(energyAvailable: UInt64, energyTotal: UInt64, bandwidthAvailable: UInt64, bandwidthTotal: UInt64) {
        self.energyAvailable = energyAvailable
        self.energyTotal = energyTotal
        self.bandwidthAvailable = bandwidthAvailable
        self.bandwidthTotal = bandwidthTotal
    }
}
