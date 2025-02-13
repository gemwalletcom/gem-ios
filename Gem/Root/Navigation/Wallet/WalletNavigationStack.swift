// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import PrimitivesComponents
import MarketInsight
import Transactions
import WalletTab

struct WalletNavigationStack: View {
    @Environment(\.keystore) private var keystore
    @Environment(\.walletService) private var walletService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.nodeService) private var nodeService
    @Environment(\.stakeService) private var stakeService
    @Environment(\.navigationState) private var navigationState

    @State private var isPresentingWallets = false
    @State private var isPresentingAssetSelectedInput: SelectedAssetInput?
    @State private var isPresentingSelectAssetType: SelectAssetType?

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
                isPresentingSelectType: $isPresentingSelectAssetType,
                isPresentingWallets: $isPresentingWallets
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Scenes.Asset.self) {
                AssetNavigationView(
                    wallet: model.wallet,
                    assetId: $0.asset.id,
                    isPresentingAssetSelectedInput: $isPresentingAssetSelectedInput
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
                        assetModel: AssetViewModel(asset: $0.asset)
                    )
                )
            }
            .sheet(item: $isPresentingSelectAssetType) { value in
                SelectAssetSceneNavigationStack(
                    model: SelectAssetViewModel(
                        wallet: model.wallet,
                        keystore: keystore,
                        selectType: value,
                        assetsService: walletsService.assetsService,
                        walletsService: walletsService
                    ),
                    isPresentingSelectType: $isPresentingSelectAssetType
                )
            }
            .sheet(item: $isPresentingAssetSelectedInput) {
              SelectedAssetNavigationStack(
                    selectType: $0,
                    wallet: model.wallet,
                    isPresentingSelectedAssetInput: $isPresentingAssetSelectedInput
                )
            }
            .sheet(isPresented: $isPresentingWallets) {
                WalletsNavigationStack(isPresentingWallets: $isPresentingWallets)
            }
        }
    }
}
