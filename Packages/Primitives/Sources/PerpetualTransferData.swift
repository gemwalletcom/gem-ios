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
    public let asset: Asset // USD
    public let perpetualAsset: Asset
    public let assetIndex: Int
    public let price: Double
    public let leverage: Int
    
    public init(
        provider: PerpetualProvider,
        direction: PerpetualDirection,
        asset: Asset,
        perpetualAsset: Asset,
        assetIndex: Int,
        price: Double,
        leverage: Int
    ) {
        self.provider = provider
        self.direction = direction
        self.asset = asset
        self.perpetualAsset = perpetualAsset
        self.assetIndex = assetIndex
        self.price = price
        self.leverage = leverage
    }
}

public struct PerpetualConfirmData: Codable, Equatable, Hashable, Sendable {
    public let direction: PerpetualDirection
    public let asset: Asset
    public let assetIndex: Int
    public let price: String
    public let fiatValue: Double
    public let size: String
    
    public init(
        direction: PerpetualDirection,
        asset: Asset,
        assetIndex: Int,
        price: String,
        fiatValue: Double,
        size: String
    ) {
        self.direction = direction
        self.asset = asset
        self.assetIndex = assetIndex
        self.price = price
        self.fiatValue = fiatValue
        self.size = size
    }
}

extension PerpetualTransferData: Identifiable {
    public var id: String {
        "\(assetIndex)_\(direction)"
    }
}
