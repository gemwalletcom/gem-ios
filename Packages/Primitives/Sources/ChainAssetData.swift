// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct ChainAssetData: Codable, Equatable, Hashable, Sendable {
    public let assetData: AssetData
    public let nativeAssetData: AssetData

    public init(assetData: AssetData, nativeAssetData: AssetData) {
        self.assetData = assetData
        self.nativeAssetData = nativeAssetData
    }
}
