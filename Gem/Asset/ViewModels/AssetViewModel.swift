import Foundation
import Primitives
import Components
import GemstonePrimitives

struct AssetViewModel {
    let asset: Asset    
    
    init(
        asset: Asset
    ) {
        self.asset = asset
    }
    
    var title: String {
        String(format: "%@ (%@)", asset.name, asset.symbol)
    }
    
    var name: String {
        asset.name
    }
    
    var symbol: String {
        asset.symbol
    }
    
    var supportMemo: Bool {
        asset.chain.isMemoSupported
    }
    
    public var assetImage: AssetImage {
        AssetIdViewModel(assetId: asset.id).assetImage
    }
}
