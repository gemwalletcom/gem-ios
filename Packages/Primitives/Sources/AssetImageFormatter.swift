
import Foundation
import Gemstone

public struct AssetImageFormatter {
    
    public static let defaultEndpoint = URL(string: Config().getPublicUrl(item: .assets))!
    
    let endpoint: URL
    
    public init(
        endpoint: URL = Self.defaultEndpoint
    ) {
        self.endpoint = endpoint
    }
    
    public func getURL(for assetId: AssetId) -> URL {
        switch assetId.type {
        case .native:
            return URL(string: String(format: "%@/blockchains/%@/info/logo.png", endpoint.absoluteString, assetId.chain.rawValue))!
        case .token:
            return URL(string: String(format: "%@/blockchains/%@/assets/%@/logo.png", endpoint.absoluteString, assetId.chain.rawValue, assetId.tokenId!))!
        }
    }
    
    public func getValidatorUrl(chain: Chain, id: String) -> URL {
        return URL(string: String(format: "%@/blockchains/%@/validators/%@/logo.png", endpoint.absoluteString, chain.rawValue, id))!
    }
}
