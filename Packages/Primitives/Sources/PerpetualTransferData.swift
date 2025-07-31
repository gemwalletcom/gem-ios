// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct PerpetualRecipientData: Codable, Equatable, Hashable, Sendable {
    public let recipient: RecipientData
    public let data: PerpetualTransferData
    
    public init(recipient: RecipientData, data: PerpetualTransferData) {
        self.recipient = recipient
        self.data = data
    }
}

extension PerpetualRecipientData: Identifiable {
    public var id: String {
        data.id
    }
}

public struct PerpetualTransferData: Codable, Equatable, Hashable, Sendable {
    public let direction: PerpetualDirection
    public let asset: Asset
    public let assetIndex: Int
    public let price: Double
    
    public init(
        direction: PerpetualDirection,
        asset: Asset,
        assetIndex: Int,
        price: Double
    ) {
        self.direction = direction
        self.asset = asset
        self.assetIndex = assetIndex
        self.price = price
    }
}

public struct PerpetualConfirmData: Codable, Equatable, Hashable, Sendable {
    public let direction: PerpetualDirection
    public let asset: Asset
    public let assetIndex: Int
    public let price: String
    public let size: String
    
    public init(
        direction: PerpetualDirection,
        asset: Asset,
        assetIndex: Int,
        price: String,
        size: String
    ) {
        self.direction = direction
        self.asset = asset
        self.assetIndex = assetIndex
        self.price = price
        self.size = size
    }
}

extension PerpetualTransferData: Identifiable {
    public var id: String {
        "\(assetIndex)_\(direction)"
    }
}
