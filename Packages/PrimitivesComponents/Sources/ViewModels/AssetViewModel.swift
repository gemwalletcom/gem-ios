import Foundation
import Primitives
import Components

public struct AssetViewModel: Sendable {
    public let asset: Asset

    public init(asset: Asset) {
        self.asset = asset
    }

    public var title: String {
        String(format: "%@ (%@)", asset.name, asset.symbol)
    }

    public var name: String {
        asset.name
    }

    public var symbol: String {
        asset.symbol
    }

    public var assetImage: AssetImage {
        AssetIdViewModel(assetId: asset.id).assetImage
    }
    
    public var networkAssetImage: AssetImage {
        AssetIdViewModel(assetId: asset.id).networkAssetImage
    }
    
    public var networkName: String {
        asset.chain.asset.name
    }
    
    public var networkFullName: String {
        switch asset.id.type {
        case .native: networkName
        case .token: "\(networkName) (\(asset.type.rawValue))"
        }
    }
}
