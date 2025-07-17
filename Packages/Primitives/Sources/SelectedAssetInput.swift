// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct SelectedAssetInput: Sendable, Hashable, Identifiable {
    public let type: SelectedAssetType
    public let assetAddress: AssetAddress

    public init(type: SelectedAssetType, assetAddress: AssetAddress) {
        self.type = type
        self.assetAddress = assetAddress
    }

    public var id: String { type.id }

    public var asset: Asset { assetAddress.asset }
    public var address: String { assetAddress.address }
}
