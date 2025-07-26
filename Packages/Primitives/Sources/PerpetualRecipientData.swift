// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct PerpetualRecipientData: Codable, Equatable, Hashable, Sendable {
    public let recipientData: RecipientData
    public let direction: PerpetualDirection
    public let asset: Asset
    
    public init(
        recipientData: RecipientData,
        direction: PerpetualDirection,
        asset: Asset
    ) {
        self.recipientData = recipientData
        self.direction = direction
        self.asset = asset
    }
}

extension PerpetualRecipientData: Identifiable {
    public var id: String {
        "\(recipientData.recipient.address)_\(direction)"
    }
}
