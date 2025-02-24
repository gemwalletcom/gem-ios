// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import NFT
import Components
import Localization
import Style

public struct CollectionsNavigationStack: View {
    @Environment(\.navigationState) private var navigationState
    @Environment(\.keystore) private var keystore
    @Environment(\.nftService) private var nftService
    @Environment(\.deviceService) private var deviceService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.avatarService) private var avatarService
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

    @State private var isPresentingReceiveSelectAssetType: SelectAssetType?
    
    @State private var model: NFTCollectionViewModel

    private var navigationPath: Binding<NavigationPath> {
        Binding(
            get: { navigationState.collections },
            set: { navigationState.collections = $0 }
        )
    }

    init(model: NFTCollectionViewModel) {
        _model = State(initialValue: model)
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
                .navigationDestination(for: Scenes.NFTDetails.self) { assetData in
                    CollectibleNavigationView(
                        model: CollectibleNavigationViewModel(
                            wallet: model.wallet,
                            assetData: assetData.assetData
                        )
                    )
                }
                .sheet(item: $isPresentingReceiveSelectAssetType) { value in
                    SelectAssetSceneNavigationStack(
                        model: SelectAssetViewModel(
                            wallet: model.wallet,
                            keystore: keystore,
                            selectType: value,
                            assetsService: walletsService.assetsService,
                            walletsService: walletsService
                        ),
                        isPresentingSelectType: $isPresentingReceiveSelectAssetType
                    )
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isPresentingReceiveSelectAssetType = .receive(.collection)
                        } label: {
                            Images.System.plus
                        }
                    }
                }
        }
        .onChange(of: keystore.currentWallet, onWalletChange)
    }
}

// MARK: - Actions

extension CollectionsNavigationStack {
    private func onWalletChange(_ _: Wallet?, wallet: Wallet?) {
        guard let wallet else { return }
        model.refresh(for: wallet)
    }

}
