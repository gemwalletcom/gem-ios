import Foundation
import Primitives
import Components

struct AssetViewModel {
    let asset: Asset    
    
    init(
        asset: Asset
    ) {
        self.asset = asset
    }
    
    var title: String {
        return String(format: "%@ (%@)", asset.name, asset.symbol)
    }
    
    var name: String {
        return asset.name
    }
    
    var symbol: String {
        return asset.symbol
    }
    
    var supportMemo: Bool {
        switch asset.chain.type {
        case .cosmos,
            .ton,
            .aptos,
            .solana,
            .xrp:
            return true
        case .bitcoin,
            .ethereum,
            .tron,
            .sui,
            .near:
            return false
        }
    }
    
    public var assetImage: AssetImage {
        return AssetIdViewModel(assetId: asset.id).assetImage
    }
}
