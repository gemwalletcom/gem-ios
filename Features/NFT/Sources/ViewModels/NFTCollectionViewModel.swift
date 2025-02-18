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
        let id: String
        let destination: any Hashable
        let assetImage: AssetImage
        let title: String
    }

    public var wallet: Wallet

    let sceneStep: Scenes.NFTCollectionScene.SceneStep
    let nftService: NFTService
    let deviceService: any DeviceServiceable
    let avatarService: AvatarService
    
    public init(
        wallet: Wallet,
        sceneStep: Scenes.NFTCollectionScene.SceneStep,
        nftService: NFTService,
        deviceService: any DeviceServiceable,
        avatarService: AvatarService
    ) {
        self.wallet = wallet
        self.sceneStep = sceneStep
        self.nftService = nftService
        self.deviceService = deviceService
        self.avatarService = avatarService
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
        guard let url = asset.image.previewImageUrl.asURL else { return }
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
            list.map { buildCollectionsGridItem(from: $0) }
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
            id: data.id,
            destination: Scenes.NFTCollectionScene(sceneStep: .collection(data)),
            assetImage: AssetImage(
                type: data.collection.name,
                imageURL: data.collection.image.imageUrl.asURL,
                placeholder: nil,
                chainPlaceholder: nil
            ),
            title: data.collection.name
        )
    }
    
    private func buildAssetDetailsGridItem(collection: NFTCollection, asset: NFTAsset) -> GridItem {
        GridItem(
            id: asset.id,
            destination: Scenes.NFTDetails(assetData: NFTAssetData(collection: collection, asset: asset)),
            assetImage: AssetImage(
                type: collection.name,
                imageURL: asset.image.imageUrl.asURL,
                placeholder: nil,
                chainPlaceholder: nil
            ),
            title: asset.name
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
