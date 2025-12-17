// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct ChainAssetData: Codable, Equatable, Hashable, Sendable {
    public let assetData: AssetData
    public let feeAssetData: AssetData

    public init(assetData: AssetData, feeAssetData: AssetData) {
        self.assetData = assetData
        self.feeAssetData = feeAssetData
    }
}
