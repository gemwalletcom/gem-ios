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

public struct NFTCollectionViewModel: Sendable {
    struct GridItem {
        let destination: any Hashable
        let assetImage: AssetImage
        let title: String
    }

    public var wallet: Wallet

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
    
    public var nftRequest: NFTRequest {
        switch sceneStep {
        case .collections:
            return NFTRequest(
                walletId: wallet.id,
                collectionId: nil
            )
        case .collection(let collection):
            return NFTRequest(
                walletId: wallet.id,
                collectionId: collection.id
            )
        }
    }
    
    var title: String {
        switch sceneStep {
        case .collections: Localized.Nft.collections
        case .collection(let collection): collection.name
        }
    }
    
    public func fetch() async {
        switch sceneStep {
        case .collections:
            await updateCollection()
        case .collection:
            break
        }
    }
    
    func updateCollection() async {
        do {
            let deviceId = try await deviceService.getDeviceId()
            try await nftService.updateAssets(deviceId: deviceId, wallet: wallet)
        } catch {
            NSLog("updateCollection error \(error)")
        }
    }
    
    func createGridItem(from data: NFTData) -> GridItem {
        if data.assets.count == 1, let asset = data.assets.first {
            GridItem(
                destination: Scenes.NFTDetails(collection: data.collection, asset: asset),
                assetImage: AssetImage(
                    imageURL: URL(string: asset.image.imageUrl),
                    placeholder: nil,
                    chainPlaceholder: nil
                ),
                title: asset.name
            )
        } else {
            GridItem(
                destination: Scenes.NFTCollectionScene(sceneStep: .collection(data.collection)),
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

extension NFTCollectionViewModel {
    func refresh(for wallet: Wallet) {
        //self.wallet = wallet
        //self.filterModel = TransactionsFilterViewModel(wallet: wallet)
        //self.request = TransactionsRequest(walletId: wallet.id, type: type)
    }
}
