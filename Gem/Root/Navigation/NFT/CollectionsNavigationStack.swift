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
    @Environment(\.nftService) private var nftService
    @Environment(\.deviceService) private var deviceService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.avatarService) private var avatarService
    @Environment(\.walletService) private var walletService
    @Environment(\.priceAlertService) private var priceAlertService

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
                .onChange(
                    of: model.currentWallet,
                    initial: true,
                    model.onChangeWallet
                )
                .navigationDestination(for: Scenes.CollectionsScene.self) {
                    CollectionsScene(
                        model: CollectionsViewModel(
                            nftService: nftService,
                            deviceService: deviceService,
                            walletService: walletService,
                            wallet: model.wallet,
                            sceneStep: $0.sceneStep
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
                .sheet(item: $model.isPresentingReceiveSelectAssetType) {
                    SelectAssetSceneNavigationStack(
                        model: SelectAssetViewModel(
                            wallet: model.wallet,
                            selectType: $0,
                            assetsService: walletsService.assetsService,
                            walletsService: walletsService,
                            priceAlertService: priceAlertService
                        ),
                        isPresentingSelectType: $model.isPresentingReceiveSelectAssetType
                    )
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: model.onSelectReceive) {
                            Images.System.plus
                        }
                    }
                }
        }
    }
}
