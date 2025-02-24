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

public struct NFTDetailsViewModel: Sendable {
    public let wallet: Wallet
    public let assetData: NFTAssetData
    private let headerButtonAction: HeaderButtonAction?
    private let avatarService: AvatarService
    
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
    
    public var title: String {
        assetData.asset.name
    }
    
    public var description: String? {
        assetData.asset.description
    }
    
    public var collectionTitle: String {
        Localized.Nft.collection
    }
    
    public var collectionText: String {
        assetData.collection.name
    }
    
    public var networkTitle: String {
        Localized.Transfer.network
    }
    
    public var networkText: String {
        assetData.asset.chain.asset.name
    }
    
    public var contractTitle: String {
        Localized.Asset.contract
    }
    
    public var networkAssetImage: AssetImage {
        AssetImage(
            imageURL: .none,
            placeholder: ChainImage(chain: assetData.asset.chain).image,
            chainPlaceholder: .none
        )
    }

    public var showContract: Bool {
        assetData.collection.contractAddress != assetData.asset.tokenId
    }
    
    public var contractText: String {
        AddressFormatter(address: contractValue, chain: assetData.asset.chain).value()
    }
    
    public var contractValue: String {
        assetData.collection.contractAddress
    }
    
    public var tokenIdTitle: String {
        Localized.Asset.tokenId
    }
    
    public var tokenIdText: String {
        if assetData.asset.tokenId.count > 16 {
            return assetData.asset.tokenId
        }
        return "#\(assetData.asset.tokenId)"
    }
    
    public var tokenIdValue: String {
        assetData.asset.tokenId
    }
    
    public var attributesTitle: String {
        Localized.Nft.properties
    }
    
    public var attributes: [NFTAttribute] {
        assetData.asset.attributes
    }
    
    public var assetImage: AssetImage {
        NFTAssetViewModel(asset: assetData.asset).assetImage
    }
    
    public var headerButtons: [HeaderButton] {
        let enabledTransferChains = [Chain.ethereum]
        return [
            HeaderButton(
                type: .send,
                isEnabled: assetData.asset.chain.isNFTSupported && enabledTransferChains.contains(assetData.asset.chain) 
            ),
            HeaderButton(type: .more, isEnabled: true),
        ]
    }
    
    public var showLinks: Bool {
        !assetData.collection.links.isEmpty
    }
    
    public var socialLinksViewModel: SocialLinksViewModel {
        SocialLinksViewModel(assetLinks: assetData.collection.links)
    }
    
    @MainActor
    func onHeaderAction(type: HeaderButtonType) {
        headerButtonAction?(type)
    }
    
    public func setWalletAvatar() async throws {
        guard let url = assetData.asset.image.previewImageUrl.asURL else { return }
        try await avatarService.save(url: url, for: wallet.id)
    }
    
    public func saveImageToGallery() async throws(ImageGalleryServiceError) {
        guard let url = assetData.asset.image.imageUrl.asURL else {
            throw ImageGalleryServiceError.wrongURL
        }
        let saver = ImageGalleryService()
        try await saver.saveImageFromURL(url)
    }
}
