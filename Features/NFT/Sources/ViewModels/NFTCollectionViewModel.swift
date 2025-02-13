// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import NFTService
import DeviceService
import Primitives
import Store
import Localization
import Style
import SwiftUI
import AvatarService

public struct NFTCollectionViewModel: Sendable {
    struct GridItem: Identifiable {
        let id = UUID()
        let destination: (any Hashable)?
        let assetImage: AssetImage
        let title: String
        let asset: NFTAsset?
    }

    public var wallet: Wallet
    public let onSelect: (@Sendable (NFTAsset?) -> Void)?

    let sceneStep: Scenes.NFTCollectionScene.SceneStep
    let nftService: NFTService
    let deviceService: any DeviceServiceable
    let avatarService: AvatarService
    
    public init(
        wallet: Wallet,
        sceneStep: Scenes.NFTCollectionScene.SceneStep,
        nftService: NFTService,
        deviceService: any DeviceServiceable,
        avatarService: AvatarService,
        onSelect: (@Sendable (NFTAsset?) -> Void)? = nil
    ) {
        self.wallet = wallet
        self.sceneStep = sceneStep
        self.nftService = nftService
        self.deviceService = deviceService
        self.avatarService = avatarService
        self.onSelect = onSelect
    }
    
    public var nftRequest: NFTRequest {
        switch sceneStep {
        case .collections:
            NFTRequest(
                walletId: wallet.id,
                collectionId: nil
            )
        case .collection(let data):
            NFTRequest(
                walletId: wallet.id,
                collectionId: data.collection.id
            )
        }
    }
    
    var title: String {
        switch sceneStep {
        case .collections: Localized.Nft.collections
        case .collection(let data): data.collection.name
        }
    }
    
    // MARK: - Public methods
    
    public func fetch() async {
        switch sceneStep {
        case .collections:
            await updateCollection()
        case .collection:
            break
        }
    }

    public func setWalletAvatar(_ asset: NFTAsset) async throws {
        guard let url = URL(string: asset.image.previewImageUrl) else { return }
        try await avatarService.save(url: url, walletId: wallet.id)
    }
    
    // MARK: - Internal methods
    
    func updateCollection() async {
        do {
            let deviceId = try await deviceService.getDeviceId()
            try await nftService.updateAssets(deviceId: deviceId, wallet: wallet)
        } catch {
            NSLog("updateCollection error \(error)")
        }
    }
    
    func createGridItems(from list: [NFTData]) -> [GridItem] {
        switch sceneStep {
        case .collections:
            list.map { data in
                buildCollectionsGridItem(from: data)
            }
        case .collection(let data):
            data.assets.map { asset in
                buildAssetDetailsGridItem(collection: data.collection, asset: asset)
            }
        }
    }
    
    // MARK: - Private methods
    
    private func buildCollectionsGridItem(from data: NFTData) -> GridItem {
        if data.assets.count == 1, let asset = data.assets.first {
            buildAssetDetailsGridItem(collection: data.collection, asset: asset)
        } else {
            buildCollectionGridItem(from: data)
        }
    }
    
    private func buildCollectionGridItem(from data: NFTData) -> GridItem {
        GridItem(
            destination: Scenes.NFTCollectionScene(sceneStep: .collection(data)),
            assetImage: AssetImage(
                type: data.collection.name,
                imageURL: URL(string: data.collection.image.imageUrl),
                placeholder: nil,
                chainPlaceholder: nil
            ),
            title: data.collection.name,
            asset: nil
        )
    }
    
    private func buildAssetDetailsGridItem(collection: NFTCollection, asset: NFTAsset) -> GridItem {
        GridItem(
            destination: onSelect == nil ? Scenes.NFTDetails(assetData: NFTAssetData(collection: collection, asset: asset)) : nil,
            assetImage: AssetImage(
                type: collection.name,
                imageURL: URL(string: asset.image.imageUrl),
                placeholder: nil,
                chainPlaceholder: nil
            ),
            title: asset.name,
            asset: asset
        )
    }
}

extension NFTCollectionViewModel {
    func refresh(for wallet: Wallet) {
        //self.wallet = wallet
        //self.filterModel = TransactionsFilterViewModel(wallet: wallet)
        //self.request = TransactionsRequest(walletId: wallet.id, type: type)
    }
}
