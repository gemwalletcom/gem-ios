// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct AssetImageFormatter: Sendable {
    
    public static let shared = AssetImageFormatter()
    
    public init() {}
    
    public func getURL(for assetId: AssetId) -> URL {
        let urlString = if let tokenId = assetId.tokenId {
            "\(Constants.assetsURL.absoluteString)/blockchains/\(assetId.chain.rawValue)/assets/\(tokenId)/logo.png"
        } else {
            "\(Constants.assetsURL.absoluteString)/blockchains/\(assetId.chain.rawValue)/logo.png"
        }
        return URL(string: urlString)!
    }
    
    public func getNFTUrl(for assetId: String) -> URL {
        URL(string: "\(Constants.apiURL.absoluteString)/v1/nft/assets/\(assetId)/image_preview")!
    }
    
    public func getValidatorUrl(chain: Chain, id: String) -> URL {
        URL(string: "\(Constants.assetsURL.absoluteString)/blockchains/\(chain.rawValue)/validators/\(id)/logo.png")!
    }
}
