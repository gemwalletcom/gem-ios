import Foundation
import SwiftUI
import Primitives
import Localization
import PrimitivesComponents
import WalletsService
import Components
import Formatters

@Observable
@MainActor
public final class ReceiveViewModel: Sendable {
    let qrWidth: CGFloat = 280
    
    let assetModel: AssetViewModel
    let walletId: WalletId
    let address: String
    let walletsService: WalletsService
    let generator = QRCodeGenerator()
    
    public var isPresentingShareSheet: Bool = false
    public var isPresentingCopyToast: Bool = false
    public var renderedImage: UIImage? = nil

    public init(
        assetModel: AssetViewModel,
        walletId: WalletId,
        address: String,
        generator: QRCodeGenerator = QRCodeGenerator(),
        walletsService: WalletsService
    ) {
        self.assetModel = assetModel
        self.walletId = walletId
        self.address = address
        self.walletsService = walletsService
    }

    var title: String {
        Localized.Receive.title("")
    }
    
    var addressShort: String {
        AddressFormatter(style: .short, address: address, chain: assetModel.asset.chain).value()
    }
    
    var addressGrouped: String {
        AddressFormatter(style: .grouped(length: 4), address: address, chain: assetModel.asset.chain).value()
    }

    var shareTitle: String {
        Localized.Common.share
    }

    var copyTitle: String {
        Localized.Common.copy
    }
    
    var symbol: String? {
        if assetModel.name == assetModel.symbol {
            return nil
        }
        return assetModel.symbol
    }
    
    var warningMessage: AttributedString {
        guard let message = try? AttributedString(markdown: Localized.Receive.warning(assetModel.symbol, assetModel.networkFullName)) else {
            return AttributedString()
        }
        return message
    }

    var copyModel: CopyTypeViewModel {
        CopyTypeViewModel(
            type: .address(assetModel.asset, address: addressShort),
            copyValue: address
        )
    }
    
    func activityItems(qrImage: UIImage?) -> [Any] {
        if let qrImage {
            return [qrImage, address]
        }
        return [address]
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

// MARK: - Actions

extension ReceiveViewModel {
    func onShareSheet() {
        isPresentingShareSheet = true
    }
    
    func onCopyAddress() {
        isPresentingCopyToast = true
    }
    
    func onLoadImage() async {
        renderedImage = await generateQRCode()
    }
}
