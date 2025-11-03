// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public struct PerpetualRecipientData: Codable, Equatable, Hashable, Sendable {
    public let recipient: RecipientData
    public let positionAction: PerpetualPositionAction

    public init(recipient: RecipientData, positionAction: PerpetualPositionAction) {
        self.recipient = recipient
        self.positionAction = positionAction
    }
}

extension PerpetualRecipientData: Identifiable {
    public var id: String { positionAction.id }
}

public enum PerpetualPositionAction: Codable, Equatable, Hashable, Sendable, Identifiable {
    case open(PerpetualTransferData)
    case reduce(PerpetualTransferData, available: BigInt, positionDirection: PerpetualDirection)
    case increase(PerpetualTransferData)

    public var id: String {
        switch self {
        case .open(let data): return data.id
        case .reduce(let data, _, _): return data.id
        case .increase(let data): return data.id
        }
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
