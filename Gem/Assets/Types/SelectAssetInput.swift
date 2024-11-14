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

    init(type: SelectAssetType, assetAddress: AssetAddress) {
        self.type = type
        self.assetAddress = assetAddress
    }
}

extension SelectAssetInput: Identifiable {
    var id: String { type.id }
}
