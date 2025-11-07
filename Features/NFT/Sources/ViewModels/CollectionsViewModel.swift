// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import NFTService
import Primitives
import Store
import Localization
import Style
import SwiftUI
import PrimitivesComponents
import AvatarService
import WalletService

@Observable
@MainActor
public final class CollectionsViewModel: Sendable {
    private let walletService: WalletService
    private let nftService: NFTService

    let columns: [GridItem] = Array(repeating: GridItem(spacing: .medium), count: 2)
    let sceneStep: Scenes.CollectionsScene.SceneStep
    var request: NFTRequest

    public var isPresentingReceiveSelectAssetType: SelectAssetType?
    public var isPresentingSelectedAssetInput: Binding<SelectedAssetInput?>

    public private(set) var wallet: Wallet

    public init(
        nftService: NFTService,
        walletService: WalletService,
        wallet: Wallet,
        sceneStep: Scenes.CollectionsScene.SceneStep,
        isPresentingSelectedAssetInput: Binding<SelectedAssetInput?>
    ) {
        self.nftService = nftService
        self.walletService = walletService

        self.wallet = wallet
        self.sceneStep = sceneStep
        self.request = Self.createNftRequest(for: wallet, sceneStep: sceneStep)
        self.isPresentingSelectedAssetInput = isPresentingSelectedAssetInput
    }

    var title: String {
        switch sceneStep {
        case .collections: Localized.Nft.collections
        case .collection(let data): data.collection.name
        }
    }

    var emptyContentModel: EmptyContentTypeViewModel {
        EmptyContentTypeViewModel(type: .nfts(action: onSelectReceive))
    }
    
    public var currentWallet: Wallet? {
        walletService.currentWallet
    }

    // MARK: - Public methods
    
    public func onChangeWallet(_ oldWallet: Wallet?, _ newWallet: Wallet?) {
        if let newWallet, wallet != newWallet {
            wallet = newWallet
            request = Self.createNftRequest(for: wallet, sceneStep: sceneStep)
        }
    }

    public func onSelectReceive() {
        isPresentingReceiveSelectAssetType = .receive(.collection)
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
            destination: Scenes.CollectionsScene(sceneStep: .collection(data)),
            assetImage: AssetImage(type: data.collection.name, imageURL: data.collection.images.preview.url.asURL),
            title: data.collection.name
        )
    }
    
    private func buildAssetDetailsGridItem(collection: NFTCollection, asset: NFTAsset) -> GridPosterViewItem {
        GridPosterViewItem(
            id: asset.id,
            destination: Scenes.Collectible(assetData: NFTAssetData(collection: collection, asset: asset)),
            assetImage: AssetImage(type: collection.name, imageURL: asset.images.preview.url.asURL),
            title: asset.name
        )
    }
    
    private func updateCollection() async {
        do {
            let count = try await nftService.updateAssets(wallet: wallet)
            
            #debugLog("update nfts: \(count)")
        } catch {
            #debugLog("update nfts error: \(error)")
        }
    }

    private static func createNftRequest(
        for wallet: Wallet,
        sceneStep: Scenes.CollectionsScene.SceneStep
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
