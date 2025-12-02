// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import PrimitivesComponents
import Localization
import Components
import Style
import ImageGalleryService
import Photos
import AvatarService
import Formatters
import ExplorerService
import InfoSheet

@Observable
@MainActor
public final class CollectibleViewModel {
    private let wallet: Wallet
    private let assetData: NFTAssetData
    private let avatarService: AvatarService
    private let explorerService: ExplorerService

    var isPresentingAlertMessage: AlertMessage?
    var isPresentingToast: ToastMessage?
    var isPresentingTokenExplorerUrl: URL?
    var isPresentingSelectedAssetInput: Binding<SelectedAssetInput?>
    var isPresentingInfoSheet: InfoSheetType?

    public init(
        wallet: Wallet,
        assetData: NFTAssetData,
        avatarService: AvatarService,
        explorerService: ExplorerService = ExplorerService.standard,
        isPresentingSelectedAssetInput: Binding<SelectedAssetInput?>
    ) {
        self.wallet = wallet
        self.assetData = assetData
        self.avatarService = avatarService
        self.explorerService = explorerService
        self.isPresentingSelectedAssetInput = isPresentingSelectedAssetInput
    }

    var title: String { assetData.asset.name }
    var description: String? { assetData.asset.description }

    var collectionTitle: String { Localized.Nft.collection }
    var collectionText: String { assetData.collection.name }

    var networkTitle: String { Localized.Transfer.network }
    var networkText: String { assetData.asset.chain.asset.name }

    var contractTitle: String { Localized.Asset.contract }
    var contractValue: String { assetData.collection.contractAddress }

    var contractText: String? {
        if contractValue.isEmpty || contractValue == assetData.asset.tokenId {
            return .none
        }
        return AddressFormatter(address: contractValue, chain: assetData.asset.chain).value()
    }
    
    var contractContextMenu: [ContextMenuItemType] {
        [.copy(value: contractValue, onCopy: { [weak self] value in
            self?.isPresentingToast = .copied(value)
        })]
    }

    var tokenIdTitle: String { Localized.Asset.tokenId }
    var tokenIdValue: String { assetData.asset.tokenId }
    var tokenIdText: String {
        if assetData.asset.tokenId.count > 16 {
            return assetData.asset.tokenId
        }
        return "#\(assetData.asset.tokenId)"
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
    
    let enabledChainTypes: Set<ChainType> = [ChainType.ethereum]

    var headerButtons: [HeaderButton] {
        [
            HeaderButton(
                type: .send,
                isEnabled: assetData.asset.chain.isNFTSupported && enabledChainTypes
                    .contains(assetData.asset.chain.type)
            ),
            HeaderButton(
                type: .more,
                viewType: .menuButton(
                    title: title,
                    items: [
                        .button(title: Localized.Nft.saveToPhotos, systemImage: SystemImage.gallery, action: onSelectSaveToGallery),
                        .button(title: Localized.Nft.setAsAvatar, systemImage: SystemImage.emoji, action: onSelectSetAsAvatar),
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
        AssetScoreTypeViewModel(scoreType: .unverified)
    }

    var showStatus: Bool {
        assetData.collection.isVerified == false
    }

    var socialLinksViewModel: SocialLinksViewModel {
        SocialLinksViewModel(assetLinks: assetData.collection.links)
    }
    
    var tokenExplorerUrl: BlockExplorerLink? {
        explorerService.tokenUrl(chain: assetData.asset.chain, address: assetData.asset.tokenId)
    }
    
    var tokenIdContextMenu: [ContextMenuItemType] {
        let items: [ContextMenuItemType] = [
            .copy(value: tokenIdValue, onCopy: { [weak self] value in
                self?.isPresentingToast = .copied(value)
            }),
            tokenExplorerUrl.map { explorerLink in
                .url(title: Localized.Transaction.viewOn(explorerLink.name), onOpen: onSelectViewTokenInExplorer)
            }
        ].compactMap { $0 }
        
        return items
    }
}

// MARK: - Business Logic

extension CollectibleViewModel {
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
                isPresentingToast = ToastMessage(title: Localized.Nft.saveToPhotos, image: SystemImage.checkmark)
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
                                action: { [weak self] in
                                    Task { @MainActor in
                                        self?.openSettings()
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
                isPresentingToast = ToastMessage(title: Localized.Nft.setAsAvatar, image: SystemImage.checkmark)
            } catch {
                debugLog("Set nft avatar error: \(error)")
            }
        }
    }
    
    func onSelectViewTokenInExplorer() {
        guard let explorerLink = tokenExplorerUrl else { return }
        guard let url = URL(string: explorerLink.link) else { return }
        isPresentingTokenExplorerUrl = url
    }

    func onSelectStatus() {
        isPresentingInfoSheet = .assetStatus(scoreViewModel.scoreType)
    }
}

// MARK: - Private

extension CollectibleViewModel {
    private func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }
    
    private func setWalletAvatar() async throws {
        guard let url = assetData.asset.images.preview.url.asURL else { return }
        try await avatarService.save(url: url, for: wallet.id)
    }

    private func saveImageToGallery() async throws(ImageGalleryServiceError) {
        guard let url = assetData.asset.images.preview.url.asURL else {
            throw ImageGalleryServiceError.wrongURL
        }
        let saver = ImageGalleryService()
        try await saver.saveImageFromURL(url)
    }
}
