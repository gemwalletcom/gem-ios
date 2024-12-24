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

    var fiatType: FiatTransactionType  {
        switch type {
        case .send, .receive, .swap, .stake, .manage, .priceAlert: fatalError(
            "fiat operations not supported"
        )
        case .buy: .buy
        case .sell: .sell
        }
    }

    init(type: SelectAssetType, assetAddress: AssetAddress) {
        self.type = type
        self.assetAddress = assetAddress
    }
}

extension SelectAssetInput: Identifiable {
    var id: String { type.id }
}
