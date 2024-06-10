// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone

public struct AssetImageFormatter {
    
    public init() {}
    
    public func getURL(for assetId: AssetId) -> URL? {
        URL(string: Config.shared.imageFormatterAssetUrl(id: assetId.identifier))
    }
    
    public func getValidatorUrl(chain: Chain, id: String) -> URL {
        URL(string: Config.shared.imageFormatterValidatorUrl(chain: chain.rawValue, id: id))!
    }
}
