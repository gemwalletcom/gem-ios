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

@Observable
@MainActor
public final class NFTCollectionViewModel: Sendable {
    private let nftService: NFTService
    private let deviceService: any DeviceServiceable

    let sceneStep: Scenes.NFTCollectionScene.SceneStep
    var request: NFTRequest

    public private(set) var wallet: Wallet

    public init(
        wallet: Wallet,
        sceneStep: Scenes.NFTCollectionScene.SceneStep,
        nftService: NFTService,
        deviceService: any DeviceServiceable
    ) {
        self.wallet = wallet
        self.sceneStep = sceneStep
        self.nftService = nftService
        self.deviceService = deviceService
        self.request = Self.createNftRequest(for: wallet, sceneStep: sceneStep)
        self.columns = Array(repeating: GridItem(spacing: Spacing.medium), count: 2)
    }
    
    let columns: [GridItem]

    var title: String {
        switch sceneStep {
        case .collections: Localized.Nft.collections
        case .collection(let data): data.collection.name
        }
    }

    // MARK: - Public methods

    public func refresh(for wallet: Wallet) {
        self.wallet = wallet
        self.request = Self.createNftRequest(for: wallet, sceneStep: sceneStep)
    }

    // MARK: - Internal methods
    
    func fetch() async {
        switch sceneStep {
        case .collections:
            await updateCollection()
        case .collection:
            break
        }
    }
    
    func createGridItems(from list: [NFTData]) -> [GridPosterViewItem] {
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
    
    private func buildCollectionsGridItem(from data: NFTData) -> GridPosterViewItem {
        if data.assets.count == 1, let asset = data.assets.first {
            buildAssetDetailsGridItem(collection: data.collection, asset: asset)
        } else {
            buildCollectionGridItem(from: data)
        }
    }
    
    private func buildCollectionGridItem(from data: NFTData) -> GridPosterViewItem {
        GridPosterViewItem(
            id: data.id,
            destination: Scenes.NFTCollectionScene(sceneStep: .collection(data)),
            assetImage: AssetImage.assetImage(type: data.collection.name, imageURL: data.collection.image.imageUrl.asURL),
            title: data.collection.name
        )
    }
    
    private func buildAssetDetailsGridItem(collection: NFTCollection, asset: NFTAsset) -> GridPosterViewItem {
        GridPosterViewItem(
            id: asset.id,
            destination: Scenes.NFTDetails(assetData: NFTAssetData(collection: collection, asset: asset)),
            assetImage: AssetImage.assetImage(type: collection.name, imageURL: asset.image.imageUrl.asURL),
            title: asset.name
        )
    }
    
    private func updateCollection() async {
        do {
            let deviceId = try await deviceService.getDeviceId()
            try await nftService.updateAssets(deviceId: deviceId, wallet: wallet)
        } catch {
            NSLog("updateCollection error \(error)")
        }
    }

    private static func createNftRequest(
        for wallet: Wallet,
        sceneStep: Scenes.NFTCollectionScene.SceneStep
    ) -> NFTRequest {
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
}

fileprivate extension AssetImage {
    static func assetImage(type: String, imageURL: URL?) -> AssetImage {
        AssetImage(
            type: type,
            imageURL: imageURL,
            placeholder: nil,
            chainPlaceholder: nil
        )
    }
}
