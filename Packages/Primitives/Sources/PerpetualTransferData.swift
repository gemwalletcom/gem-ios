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
    public let provider: PerpetualProvider
    public let direction: PerpetualDirection
    public let asset: Asset
    public let baseAsset: Asset // USD
    public let assetIndex: Int
    public let price: Double
    public let leverage: Int
    
    public init(
        provider: PerpetualProvider,
        direction: PerpetualDirection,
        asset: Asset,
        baseAsset: Asset,
        assetIndex: Int,
        price: Double,
        leverage: Int
    ) {
        self.provider = provider
        self.direction = direction
        self.asset = asset
        self.baseAsset = baseAsset
        self.assetIndex = assetIndex
        self.price = price
        self.leverage = leverage
    }
}

extension PerpetualTransferData: Identifiable {
    public var id: String {
        "\(assetIndex)_\(direction)"
    }
}
