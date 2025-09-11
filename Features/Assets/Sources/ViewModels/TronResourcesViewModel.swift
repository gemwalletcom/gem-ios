// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

public struct TronResourcesViewModel: Sendable {
    private let metadata: BalanceMetadata
    
    public init(metadata: BalanceMetadata) {
        self.metadata = metadata
    }
    
    public var energyText: String {
        "\(metadata.energyAvailable)/\(metadata.energyTotal)"
    }
    
    public var bandwidthText: String {
        "\(metadata.bandwidthAvailable)/\(metadata.bandwidthTotal)"
    }
    
    public var energyTitle: String {
        "Energy"
    }
    
    public var bandwidthTitle: String {
        "Bandwidth"
    }
    
    public var energyPercentage: Double {
        guard metadata.energyTotal > 0 else { return 0 }
        return Double(metadata.energyAvailable) / Double(metadata.energyTotal)
    }
    
    public var bandwidthPercentage: Double {
        guard metadata.bandwidthTotal > 0 else { return 0 }
        return Double(metadata.bandwidthAvailable) / Double(metadata.bandwidthTotal)
    }
}