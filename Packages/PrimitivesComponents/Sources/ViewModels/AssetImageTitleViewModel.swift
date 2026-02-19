// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components

public struct AssetImageTitleViewModel: Sendable {
    private let asset: Asset

    public init(asset: Asset) {
        self.asset = asset
    }

    public var name: String { asset.name }
    public var assetImage: AssetImage { AssetIdViewModel(assetId: asset.id).assetImage }

    public var symbol: String? {
        if asset.name == asset.symbol {
            return nil
        }
        return asset.symbol
    }
}
