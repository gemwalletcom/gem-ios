// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization
import PrimitivesComponents

struct WalletNavigationStack: View {
    @Environment(\.keystore) private var keystore
    @Environment(\.walletService) private var walletService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.nodeService) private var nodeService
    @Environment(\.stakeService) private var stakeService
    @Environment(\.navigationState) private var navigationState
    @Environment(\.nftService) private var nftService
    @Environment(\.deviceService) private var deviceService

    @State private var isPresentingWallets = false
    @State private var isPresentingAssetSelectType: SelectAssetInput?
    @State private var isPresentingSelectType: SelectAssetType?

    let model: WalletSceneViewModel
    
    private var navigationPath: Binding<NavigationPath> {
        Binding(
            get: { navigationState.wallet },
            set: { navigationState.wallet = $0 }
        )
    }

    var body: some View {
        NavigationStack(path: navigationPath) {
            WalletScene(
                model: model,
                isPresentingSelectType: $isPresentingSelectType,
                isPresentingWallets: $isPresentingWallets
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Scenes.Asset.self) {
                AssetNavigationView(
                    wallet: model.wallet,
                    assetId: $0.asset.id,
                    isPresentingAssetSelectType: $isPresentingAssetSelectType
                )
            }
            .navigationDestination(for: TransactionExtended.self) {
                TransactionScene(
                    input: TransactionSceneInput(transactionId: $0.id, walletId: model.wallet.walletId)
                )
            }
            .navigationDestination(for: Scenes.Price.self) {
                ChartScene(
                    model: ChartsViewModel(
                        priceService: walletsService.priceService,
                        assetsService: walletsService.assetsService,
                        assetModel: AssetViewModel(asset: $0.asset)
                    )
                )
            }
            .navigationDestination(for: Scenes.NFTCollectionScene.self) {
                NFTCollectionScene(
                    model: NFTCollectionViewModel(
                        wallet: model.wallet,
                        sceneStep: $0.sceneStep,
                        nftService: nftService,
                        deviceService: deviceService
                    )
                )
            }
            .navigationDestination(for: Scenes.NFTDetails.self) {
                NFTDetailsScene(collection: $0.collection, asset: $0.asset)
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
            .sheet(item: $isPresentingAssetSelectType) {
                SelectedAssetNavigationStack(
                    selectType: $0,
                    wallet: model.wallet,
                    isPresentingAssetSelectType: $isPresentingAssetSelectType
                )
            }
            .sheet(isPresented: $isPresentingWallets) {
                WalletsNavigationStack(isPresentingWallets: $isPresentingWallets)
            }
        }
    }
}
