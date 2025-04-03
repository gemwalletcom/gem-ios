import Foundation
import SwiftUI
import Primitives
import Localization
import PrimitivesComponents
import WalletsService
import Components

struct ReceiveViewModel {
    let qrWidth: CGFloat = 300
    
    let assetModel: AssetViewModel
    let walletId: WalletId
    let address: String
    let walletsService: WalletsService
    let generator = QRCodeGenerator()
    
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

    var copyModel: CopyTypeViewModel {
        CopyTypeViewModel(
            type: .address(assetModel.asset, address: addressShort),
            copyValue: address
        )
    }
    
    func activityItems(qrImage: UIImage?) -> [Any] {
        [
            qrImage as Any,
            Localized.Receive.myAddress(assetModel.networkFullName, assetModel.symbol),
            address
        ].compactMap { $0 }
    }
    
    func enableAsset() async {
        await walletsService.enableAssets(walletId: walletId, assetIds: [assetModel.asset.id], enabled: true)
    }
    
    func generateQRCode() async -> UIImage? {
        await generator.generate(
            from: address,
            size: CGSize(
                width: qrWidth,
                height: qrWidth
            ),
            logo: UIImage.name("logo-dark")
        )
    }
}
