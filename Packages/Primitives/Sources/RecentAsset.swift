// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct RecentAsset: Sendable, Identifiable, Equatable {
    public let asset: Asset
    public let createdAt: Date

    public var id: String { asset.id.identifier }

    public init(asset: Asset, createdAt: Date) {
        self.asset = asset
        self.createdAt = createdAt
    }
}
