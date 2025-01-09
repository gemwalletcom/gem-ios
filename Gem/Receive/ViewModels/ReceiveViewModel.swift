import Foundation
import Primitives
import Localization
import PrimitivesComponents

struct ReceiveViewModel {
    
    let assetModel: AssetViewModel
    let walletId: WalletId
    let address: String
    let walletsService: WalletsService
    
    var title: String {
        Localized.Receive.title(assetModel.symbol)
    }
    
    var addressShort: String {
        AddressFormatter(style: .short, address: address, chain: assetModel.asset.chain).value()
    }

    var youAddressTitle: String {
        Localized.Receive.yourAddress
    }

    var shareTitle: String {
        Localized.Common.share
    }

    var copyTitle: String {
        Localized.Common.copy
    }

    func enableAsset() {
        walletsService.enableAssetId(walletId: walletId, assets: [assetModel.asset.id], enabled: true)
    }
}
