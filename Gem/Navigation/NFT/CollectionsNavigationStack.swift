// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import NFT
import Components
import Localization
import Style
import Assets
import AssetsService

struct CollectionsNavigationStack: View {
    @Environment(\.navigationState) private var navigationState
    @Environment(\.nftService) private var nftService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.avatarService) private var avatarService
    @Environment(\.walletService) private var walletService
    @Environment(\.priceAlertService) private var priceAlertService
    @Environment(\.assetsService) private var assetsService
    @Environment(\.activityService) private var activityService

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
                            walletService: walletService,
                            wallet: model.wallet,
                            sceneStep: $0.sceneStep,
                            isPresentingSelectedAssetInput: model.isPresentingSelectedAssetInput
                        )
                    )
                }
                .navigationDestination(for: Scenes.Collectible.self) {
                    CollectibleScene(
                        model: CollectibleViewModel(
                            wallet: model.wallet,
                            assetData: $0.assetData,
                            avatarService: avatarService,
                            isPresentingSelectedAssetInput: model.isPresentingSelectedAssetInput
                        )
                    )
                }
                .sheet(item: $model.isPresentingReceiveSelectAssetType) {
                    SelectAssetSceneNavigationStack(
                        model: SelectAssetViewModel(
                            wallet: model.wallet,
                            selectType: $0,
                            searchService: AssetSearchService(assetsService: assetsService),
                            walletsService: walletsService,
                            priceAlertService: priceAlertService,
                            activityService: activityService
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
