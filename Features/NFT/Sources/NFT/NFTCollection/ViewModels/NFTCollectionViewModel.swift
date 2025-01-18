// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import NFTService
import DeviceService
import Primitives
import Store
import Localization

public struct NFTCollectionViewModel: Sendable {
    struct GridItem {
        let destination: any Hashable
        let assetImage: AssetImage
        let title: String
    }

    let wallet: Wallet
    let sceneStep: Scenes.NFTCollectionScene.SceneStep
    let nftService: NFTService
    let deviceService: any DeviceServiceable
    
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
    }
    
    var nftRequest: NFTRequest {
        switch sceneStep {
        case .collections:
            return NFTRequest(
                walletId: wallet.id,
                collectionId: nil
            )
        case .nft(let collectionId):
            return NFTRequest(
                walletId: wallet.id,
                collectionId: collectionId
            )
        }
    }
    
    func title(list: [NFTData]) -> String {
        switch sceneStep {
        case .collections:
            if list.count == 1 {
                fallthrough
            } else {
                return Localized.Nft.collections
            }
        case .nft:
            return Localized.Nft.yourNfts
        }
    }
    
    func taskOnce() async {
        switch sceneStep {
        case .collections:
            await updateNFT()
        case .nft:
            break
        }
    }
    
    func updateNFT() async {
        do {
            let deviceId = try await deviceService.getDeviceId()
            try await nftService.updateNFT(deviceId: deviceId, wallet: wallet)
        } catch {
            NSLog("updateNFT error \(error)")
        }
    }
    
    func createGridItem(from data: NFTData) -> GridItem {
        if data.assets.count == 1, let asset = data.assets.first {
            return GridItem(
                destination: Scenes.NFTDetails(collection: data.collection, asset: asset),
                assetImage: AssetImage(
                    imageURL: URL(string: asset.image.imageUrl),
                    placeholder: nil,
                    chainPlaceholder: nil
                ),
                title: asset.name
            )
        } else {
            return GridItem(
                destination: Scenes.NFTCollectionScene(sceneStep: .nft(collectionId: data.collection.id)),
                assetImage: AssetImage(
                    imageURL: URL(string: data.collection.image.imageUrl),
                    placeholder: nil,
                    chainPlaceholder: nil
                ),
                title: data.collection.name
            )
        }
    }
}
