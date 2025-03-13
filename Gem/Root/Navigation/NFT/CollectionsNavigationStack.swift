// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import NFT
import Components
import Localization
import Style

struct CollectionsNavigationStack: View {
    @Environment(\.navigationState) private var navigationState
    @Environment(\.keystore) private var keystore
    @Environment(\.nftService) private var nftService
    @Environment(\.deviceService) private var deviceService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.avatarService) private var avatarService
    @Environment(\.priceAlertService) private var priceAlertService

    @State private var isPresentingReceiveSelectAssetType: SelectAssetType?
    
    @State private var model: CollectionsViewModel

    private var navigationPath: Binding<NavigationPath> {
        Binding(
            get: { navigationState.collections },
            set: { navigationState.collections = $0 }
        )
    }

    init(model: CollectionsViewModel) {
        _model = State(initialValue: model)
    }
    
    public var body: some View   {
        NavigationStack(path: navigationPath) {
            CollectionsScene(model: model)
                .navigationDestination(for: Scenes.CollectionsScene.self) {
                    CollectionsScene(
                        model: CollectionsViewModel(
                            wallet: model.wallet,
                            sceneStep: $0.sceneStep,
                            nftService: nftService,
                            deviceService: deviceService
                        )
                    )
                }
                .navigationDestination(for: Scenes.Collectible.self) {
                    CollectibleNavigationView(
                        model: CollectibleNavigationViewModel(
                            wallet: model.wallet,
                            assetData: $0.assetData
                        )
                    )
                }
                .sheet(item: $isPresentingReceiveSelectAssetType) {
                    SelectAssetSceneNavigationStack(
                        model: SelectAssetViewModel(
                            wallet: model.wallet,
                            keystore: keystore,
                            selectType: $0,
                            assetsService: walletsService.assetsService,
                            walletsService: walletsService,
                            priceAlertService: priceAlertService
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
