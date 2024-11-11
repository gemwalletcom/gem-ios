import Foundation
import Primitives

struct SelectAssetInput: Hashable {
    let type: SelectAssetType
    let assetAddress: AssetAddress
    let availableBalance: Double?

    var asset: Asset  {
        assetAddress.asset
    }
    
    var address: String {
        assetAddress.address
    }

    init(type: SelectAssetType, assetAddress: AssetAddress, availableBalance: Double?) {
        self.type = type
        self.assetAddress = assetAddress
        self.availableBalance = availableBalance
    }
}

extension SelectAssetInput: Identifiable {
    var id: String { type.rawValue }
}
