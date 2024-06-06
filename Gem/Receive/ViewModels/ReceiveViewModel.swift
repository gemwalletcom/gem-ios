import Foundation
import Primitives

struct ReceiveViewModel {
    
    let assetModel: AssetViewModel
    let wallet: Wallet
    let address: String
    let walletService: WalletService
    
    var title: String {
        Localized.Receive.title(assetModel.symbol)
    }
    
    var addressShort: String {
        return AddressFormatter(style: .short, address: address, chain: assetModel.asset.chain).value()
    }
    
    var sharableText: String {
        return address
    }
    
    var footerMessage: String {
        return "This address can only be used to receive ETH and ETH tokens on Ethereum"
    }
    
    func enableAsset() {
        walletService.enableAssetId(wallet: wallet, assets: [assetModel.asset.id], enabled: true)
    }
}
