// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import PrimitivesComponents
import Localization
import Components
import Style
import ImageGalleryService
import AvatarService
import Formatters
import ExplorerService
import NFTService
import InfoSheet

@Observable
@MainActor
public final class CollectibleViewModel {
    private let wallet: Wallet
    private let avatarService: AvatarService
    private let explorerService: ExplorerService

    let assetData: NFTAssetData
    let nftService: NFTService

    var isPresentingAlertMessage: AlertMessage?
    var isPresentingToast: ToastMessage?
    var isPresentingSelectedAssetInput: Binding<SelectedAssetInput?>
    var isPresentingReportSheet = false
    var isPresentingInfoSheet: InfoSheetType?
    var isImageLoaded = false

    public init(
        wallet: Wallet,
        assetData: NFTAssetData,
        avatarService: AvatarService,
        nftService: NFTService,
        explorerService: ExplorerService = ExplorerService.standard,
        isPresentingSelectedAssetInput: Binding<SelectedAssetInput?>
    ) {
        self.wallet = wallet
        self.assetData = assetData
        self.avatarService = avatarService
        self.nftService = nftService
        self.explorerService = explorerService
        self.isPresentingSelectedAssetInput = isPresentingSelectedAssetInput
    }

    var title: String { assetData.asset.name }

    var imageContextMenuItems: [ContextMenuItemType] {
        guard isImageLoaded else { return [] }
        return [
            .custom(
                title: Localized.Nft.saveToPhotos,
                systemImage: SystemImage.gallery,
                action: onSelectSaveToGallery
            ),
            .custom(
                title: Localized.Nft.setAsAvatar,
                systemImage: SystemImage.emoji,
                action: onSelectSetAsAvatar
            ),
        ]
    }

    var collectionField: ListItemField {
        ListItemField(title: Localized.Nft.collection, value: assetData.collection.name)
    }

    var isVerified: Bool {
        assetData.collection.status == .verified
    }

    var networkField: ListItemField {
        ListItemField(title: Localized.Transfer.network, value: assetData.asset.chain.asset.name)
    }

    var contractField: ListItemField? {
        if contractValue.isEmpty || contractValue == assetData.asset.tokenId {
            return .none
        }
        let text = AddressFormatter(address: contractValue, chain: assetData.asset.chain).value()
        return ListItemField(title: Localized.Asset.contract, value: text)
    }

    var contractExplorerLink: BlockExplorerLink? {
        explorerService.tokenUrl(chain: assetData.asset.chain, address: contractValue)
    }

    var contractExplorerContext: ExplorerContextData? {
        contractExplorerLink.map {
            ExplorerContextData(copyValue: .address(value: contractValue, chain: assetData.asset.chain), explorerLink: $0)
        }
    }

    var contractRow: CollectibleInfoRow? {
        contractField.map {
            CollectibleInfoRow(
                field: $0,
                action: contractExplorerContext.map { .explorer($0) } ?? .copy(contractValue)
            )
        }
    }

    var tokenIdValue: String { assetData.asset.tokenId }
    var tokenIdField: ListItemField {
        let text = if assetData.asset.tokenId.count > 16 {
            AddressFormatter(address: assetData.asset.tokenId, chain: assetData.asset.chain).value()
        } else {
            "#\(assetData.asset.tokenId)"
        }
        return ListItemField(title: Localized.Asset.tokenId, value: text)
    }

    var tokenIdExplorerLink: BlockExplorerLink? {
        explorerService.nftUrl(
            chain: assetData.asset.chain,
            contractAddress: contractValue,
            tokenId: tokenIdValue
        )
    }

    var tokenIdExplorerContext: ExplorerContextData? {
        tokenIdExplorerLink.map {
            ExplorerContextData(copyValue: .plain(tokenIdValue), explorerLink: $0)
        }
    }

    var attributesTitle: String { Localized.Nft.properties }
    var attributes: [NFTAttribute] { assetData.asset.attributes }

    var assetImage: AssetImage {
        NFTAssetViewModel(asset: assetData.asset).assetImage
    }

    var networkAssetImage: AssetImage {
        AssetImage(
            imageURL: .none,
            placeholder: ChainImage(chain: assetData.asset.chain).image,
            chainPlaceholder: .none
        )
    }
    
    var isSendEnabled: Bool {
        wallet.canSign &&
        assetData.asset.chain.isNFTSupported &&
        Self.enabledChainTypes.contains(assetData.asset.chain.type)
    }
    
    var headerButtons: [HeaderButton] {
        [
            HeaderButton(
                type: .send,
                isEnabled: isSendEnabled
            ),
            HeaderButton(
                type: .more,
                viewType: .menuButton(
                    title: title,
                    items: [
                        .button(title: Localized.Nft.saveToPhotos, systemImage: SystemImage.gallery, action: onSelectSaveToGallery),
                        .button(title: Localized.Nft.setAsAvatar, systemImage: SystemImage.emoji, action: onSelectSetAsAvatar),
                        .button(title: Localized.Nft.Report.reportButtonTitle, role: .destructive, action: onSelectReport),
                    ]
                ),
                isEnabled: true
            ),
        ]
    }

    var showAttributes: Bool {
        attributes.isNotEmpty
    }

    var showLinks: Bool {
        assetData.collection.links.isNotEmpty
    }

    var scoreViewModel: AssetScoreTypeViewModel {
        AssetScoreTypeViewModel(scoreType: AssetScoreType(verificationStatus: assetData.collection.status))
    }

    var showStatus: Bool {
        assetData.collection.status != .verified
    }

    var socialLinksViewModel: SocialLinksViewModel {
        SocialLinksViewModel(assetLinks: assetData.collection.links)
    }
    
    var tokenIdRow: CollectibleInfoRow {
        CollectibleInfoRow(
            field: tokenIdField,
            action: tokenIdExplorerContext.map { .explorer($0) } ?? .copy(tokenIdValue)
        )
    }
}

// MARK: - Business Logic

extension CollectibleViewModel {
    func onSelectCopyValue(_ value: CopyValue) {
        isPresentingToast = .copied(value.displayValue)
    }

    func onSelectCopyValue(_ value: String) {
        isPresentingToast = .copied(value)
    }

    func onSelectHeaderButton(type: HeaderButtonType) {
        guard let account = try? wallet.account(for: assetData.asset.chain) else {
            return
        }
        switch type {
        case .send:
            isPresentingSelectedAssetInput.wrappedValue = SelectedAssetInput(
                type: .send(.nft(assetData.asset)),
                assetAddress: AssetAddress(asset: account.chain.asset, address: account.address)
            )
        case .buy, .sell, .receive, .swap, .stake, .more, .deposit, .withdraw:
            fatalError()
        }
    }

    func onSelectSaveToGallery() {
        Task {
            do {
                try await saveImageToGallery()
                isPresentingToast = .success(Localized.Nft.saveToPhotos)
            } catch let error as ImageGalleryServiceError {
                switch error {
                case .wrongURL, .invalidData, .invalidResponse, .unexpectedStatusCode, .urlSessionError:
                    isPresentingAlertMessage = AlertMessage(message: Localized.Errors.errorOccured)
                case .permissionDenied:
                    isPresentingAlertMessage = AlertMessage(
                        title: Localized.Permissions.accessDenied,
                        message: Localized.Permissions.Image.PhotoAccess.Denied.description,
                        actions: [
                            AlertAction(
                                title: Localized.Common.openSettings,
                                isDefaultAction: true,
                                action: {
                                    Task { @MainActor in
                                        self.openSettings()
                                    }
                                }
                            ),
                            .cancel(title: Localized.Common.cancel)
                        ]
                    )
                }
            }
        }
    }

    func onSelectSetAsAvatar() {
        Task {
            do {
                try await setWalletAvatar()
                isPresentingToast = .success(Localized.Nft.setAsAvatar)
            } catch {
                debugLog("Set nft avatar error: \(error)")
            }
        }
    }
    
    func onSelectReport() {
        isPresentingReportSheet = true
    }

    func onReportComplete() {
        isPresentingReportSheet = false
        isPresentingToast = .success(Localized.Transaction.Status.confirmed)
	}

    func onSelectStatus() {
        isPresentingInfoSheet = .assetStatus(scoreViewModel.scoreType)
    }
}

// MARK: - Private

extension CollectibleViewModel {
    private static let enabledChainTypes: Set<ChainType> = [.ethereum]
    private var contractValue: String { assetData.collection.contractAddress }

    private func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }

    private func setWalletAvatar() async throws {
        guard let url = assetData.asset.images.preview.url.asURL else { return }
        try await avatarService.save(url: url, for: wallet)
    }

    private func saveImageToGallery() async throws(ImageGalleryServiceError) {
        guard let url = assetData.asset.images.preview.url.asURL else {
            throw ImageGalleryServiceError.wrongURL
        }
        let saver = ImageGalleryService()
        try await saver.saveImageFromURL(url)
    }
}
