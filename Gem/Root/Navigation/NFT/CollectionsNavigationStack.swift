// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import NFT

public struct CollectionsNavigationStack: View {
    
    @Environment(\.navigationState) private var navigationState
    @Environment(\.nftService) private var nftService
    @Environment(\.deviceService) private var deviceService
    
    let model: NFTCollectionViewModel
    
    private var navigationPath: Binding<NavigationPath> {
        Binding(
            get: { navigationState.collections },
            set: { navigationState.collections = $0 }
        )
    }
    
    public var body: some View   {
        NavigationStack(path: navigationPath) {
            NFTScene(model: model)
                .navigationDestination(for: Scenes.NFTCollectionScene.self) {
                    NFTScene(
                        model: NFTCollectionViewModel(
                            wallet: model.wallet,
                            sceneStep: $0.sceneStep,
                            nftService: nftService,
                            deviceService: deviceService
                        )
                    )
                }
                .navigationDestination(for: Scenes.NFTDetails.self) {
                    NFTDetailsScene(
                        model: NFTDetailsViewModel(collection: $0.collection, asset: $0.asset)
                    )
                }
        }
        
    }
}
