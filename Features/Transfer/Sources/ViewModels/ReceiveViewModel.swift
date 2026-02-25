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
    var qrSize: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 180 : 260
    }
    
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

    var shareTitle: String {
        Localized.Common.share
    }

    var copyTitle: String {
        Localized.Common.copy
    }

    var assetImageTitleModel: AssetImageTitleViewModel {
        AssetImageTitleViewModel(asset: assetModel.asset)
    }

    var warningMessage: AttributedString {
        let warning = Localized.Receive.warning(assetModel.symbol.boldMarkdown(), assetModel.networkFullName.boldMarkdown())
        guard let message = try? AttributedString(markdown: [warning, memoWarningText].compactMap { $0 }.joined(separator: " ")) else {
            return AttributedString()
        }
        return message
    }

    private var memoWarningText: String? {
        switch assetModel.asset.chain {
        case .xrp where assetModel.asset.chain.isMemoSupported: Localized.Wallet.Receive.noDestinationTagRequired
        case _ where assetModel.asset.chain.isMemoSupported: Localized.Wallet.Receive.noMemoRequired
        default: nil
        }
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
        do {
            try await walletsService.enableAssets(walletId: walletId, assetIds: [assetModel.asset.id], enabled: true)
        } catch {
            debugLog("ReceiveViewModel enableAsset error: \(error)")
        }
    }
    
    func generateQRCode() async -> UIImage? {
        await generator.generate(
            from: address,
            size: CGSize(
                width: qrSize,
                height: qrSize
            ),
            logo: UIImage.name("logo-dark")
        )
    }
}

// MARK: - Actions

extension ReceiveViewModel {
    func onTaskOnce() {
        Task {
            await enableAsset()
        }
    }

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
