// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import NFT

public struct CollectionsNavigationStack: View {
    
    @Environment(\.keystore) private var keystore
    @Environment(\.navigationState) private var navigationState
    @Environment(\.nftService) private var nftService
    @Environment(\.deviceService) private var deviceService
    @Environment(\.walletsService) private var walletsService
    
    @State private var isPresentingSelectType: SelectAssetType?
    
    let model: NFTCollectionViewModel
    
    private var navigationPath: Binding<NavigationPath> {
        Binding(
            get: { navigationState.collections },
            set: { navigationState.collections = $0 }
        )
    }
    
    public var body: some View   {
        NavigationStack(path: navigationPath) {
            NFTScene(model: model, isPresentingSelectType: $isPresentingSelectType)
            .navigationDestination(for: Scenes.NFTCollectionScene.self) {
                NFTScene(
                    model: NFTCollectionViewModel(
                        wallet: model.wallet,
                        sceneStep: $0.sceneStep,
                        nftService: nftService,
                        deviceService: deviceService
                    ),
                    isPresentingSelectType: $isPresentingSelectType
                )
            }
            .navigationDestination(for: Scenes.NFTDetails.self) {
                NFTDetailsScene(
                    model: NFTDetailsViewModel(collection: $0.collection, asset: $0.asset)
                )
            }
            .sheet(item: $isPresentingSelectType) { value in
                SelectAssetSceneNavigationStack(
                    model: SelectAssetViewModel(
                        wallet: model.wallet,
                        keystore: keystore,
                        selectType: value,
                        assetsService: walletsService.assetsService,
                        walletsService: walletsService
                    ),
                    isPresentingSelectType: $isPresentingSelectType
                )
            }
        }
        .onChange(of: keystore.currentWallet, onWalletChange)
    }
}

extension CollectionsNavigationStack {
    private func onWalletChange(_ _: Wallet?, wallet: Wallet?) {
        Task {
            await model.fetch()
        }
    }
}
