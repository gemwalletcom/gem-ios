// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Localization
import Components
import Style
import ImageGalleryService
import Photos
import AvatarService
import Formatters

@Observable
@MainActor
public final class CollectibleViewModel {
    private let wallet: Wallet
    private let assetData: NFTAssetData
    private let headerButtonAction: HeaderButtonAction?
    private let avatarService: AvatarService

    var isPresentingPhotoPermissionMessage: Bool = false
    var isPresentingErrorMessage: String?
    var isPresentingSaveToPhotosToast = false
    var isPresentingSetAsAvatarToast = false

    public init(
        wallet: Wallet,
        assetData: NFTAssetData,
        avatarService: AvatarService,
        headerButtonAction: HeaderButtonAction?
    ) {
        self.wallet = wallet
        self.assetData = assetData
        self.avatarService = avatarService
        self.headerButtonAction = headerButtonAction
    }

    var title: String { assetData.asset.name }
    var description: String? { assetData.asset.description }

    var collectionTitle: String { Localized.Nft.collection }
    var collectionText: String { assetData.collection.name }

    var networkTitle: String { Localized.Transfer.network }
    var networkText: String { assetData.asset.chain.asset.name }

    var contractTitle: String { Localized.Asset.contract }
    var contractValue: String { assetData.collection.contractAddress }

    var contractText: String {
        AddressFormatter(address: contractValue, chain: assetData.asset.chain).value()
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

    var headerButtons: [HeaderButton] {
        let enabledTransferChains = [Chain.ethereum]
        return [
            HeaderButton(
                type: .send,
                isEnabled: assetData.asset.chain.isNFTSupported && enabledTransferChains.contains(assetData.asset.chain)
            ),
            HeaderButton(
                type: .more,
                viewType: .menuButton(
                    title: title,
                    items: [.button(title: Localized.Nft.saveToPhotos, systemImage: SystemImage.gallery, action: onSelectSaveToGallery),
                            .button(title: Localized.Nft.setAsAvatar, systemImage: SystemImage.emoji, action: onSelectSetAsAvatar)]
                ),
                isEnabled: true
            ),
        ]
    }

    var showContract: Bool {
        assetData.collection.contractAddress != assetData.asset.tokenId
    }

    var showAttributes: Bool {
        !attributes.isEmpty
    }

    var showLinks: Bool {
        !assetData.collection.links.isEmpty
    }

    var socialLinksViewModel: SocialLinksViewModel {
        SocialLinksViewModel(assetLinks: assetData.collection.links)
    }
}

// MARK: - Business Logic

extension CollectibleViewModel {
    func onHeaderAction(type: HeaderButtonType) {
        headerButtonAction?(type)
    }

    func onSelectSaveToGallery() {
        Task {
            do {
                try await saveImageToGallery()
                isPresentingSaveToPhotosToast = true
            } catch let error as ImageGalleryServiceError {
                switch error {
                case .wrongURL, .invalidData, .invalidResponse, .unexpectedStatusCode, .urlSessionError:
                    isPresentingErrorMessage = Localized.Errors.errorOccured
                case .permissionDenied:
                    isPresentingPhotoPermissionMessage = true
                }
            }
        }
    }

    func onSelectSetAsAvatar() {
        Task {
            do {
                try await setWalletAvatar()
                isPresentingSetAsAvatarToast = true
            } catch {
                NSLog("Set nft avatar error: \(error)")
            }
        }
    }
}

// MARK: - Private

extension CollectibleViewModel {
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
