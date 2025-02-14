// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import class Gemstone.Config

public struct AssetImageFormatter: Sendable {
    
    public init() {}
    
    public func getURL(for assetId: Primitives.AssetId) -> URL? {
        URL(string: Config.shared.imageFormatterAssetUrl(chain: assetId.chain.rawValue, tokenId: assetId.tokenId))
    }
    
    public func getValidatorUrl(chain: Primitives.Chain, id: String) -> URL? {
        URL(string: Config.shared.imageFormatterValidatorUrl(chain: chain.rawValue, id: id))
    }
}
