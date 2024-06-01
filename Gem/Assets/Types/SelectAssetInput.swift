import Foundation
import Primitives

struct SelectAssetInput: Hashable {
    let type: SelectAssetType
    let assetAddress: AssetAddress
    
    var asset: Asset  {
        assetAddress.asset
    }
    
    var address: String {
        assetAddress.address
    }
}

extension SelectAssetInput: Identifiable {
    var id: String { type.rawValue }
}
