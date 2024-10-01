// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives

struct WalletNavigationStack: View {
    @Environment(\.keystore) private var keystore
    @Environment(\.walletService) private var walletService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.nodeService) private var nodeService
    @Environment(\.stakeService) private var stakeService
    @Environment(\.navigationState) private var navigationState

    @State private var isWalletsPresented = false
    @State private var isPresentingCreateWalletSheet = false
    @State private var isPresentingImportWalletSheet = false
    @State private var isPresentingAssetSelectType: SelectAssetInput?
    @State private var isPresentingSelectType: SelectAssetType?

    let model: WalletSceneViewModel
    @State private var navigationPathSelectType = NavigationPath()

    var body: some View {
        @Bindable var navigationState = navigationState
        NavigationStack(path: $navigationState.wallet) {
            WalletScene(
                model: model,
                isPresentingSelectType: $isPresentingSelectType
            )
            .sheet(isPresented: $isWalletsPresented) {
                WalletsNavigationStack()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Scenes.Asset.self) { asset in
                @Bindable var navigationState = navigationState
                AssetNavigationView(
                    wallet: model.wallet,
                    assetId: asset.asset.id,
                    isPresentingAssetSelectType: $isPresentingAssetSelectType,
                    navigationPath: $navigationState.wallet
                )
            }
            .navigationDestination(for: TransactionExtended.self) { transaction in
                TransactionScene(
                    input: TransactionSceneInput(transactionId: transaction.id, walletId: model.wallet.walletId)
                )
            }
            .navigationDestination(for: Scenes.Stake.self) {
                StakeNavigationView(wallet: $0.wallet, assetId: $0.chain.assetId)
            }
            .navigationDestination(for: Scenes.Price.self) { scene in
                ChartScene(
                    model: ChartsViewModel(
                        priceService: walletsService.priceService,
                        assetsService: walletsService.assetsService,
                        assetModel: AssetViewModel(asset: scene.asset)
                    )
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
                    navigationPath: $navigationPathSelectType
                )
            }
            .sheet(item: $isPresentingAssetSelectType) { selectType in
                NavigationStack {
                    switch selectType.type {
                    case .send:
                        AmountNavigationView(
                            input: AmountInput(type: .transfer, asset: selectType.asset),
                            wallet: model.wallet
                        )
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(Localized.Common.done) {
                                    isPresentingAssetSelectType = nil
                                }.bold()
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                    case .receive:
                        ReceiveScene(
                            model: ReceiveViewModel(
                                assetModel: AssetViewModel(asset: selectType.asset),
                                walletId: model.wallet.walletId,
                                address: selectType.address,
                                walletsService: walletsService
                            )
                        )
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(Localized.Common.done) {
                                    isPresentingAssetSelectType = nil
                                }.bold()
                            }
                        }
                    case .buy:
                        BuyAssetScene(
                            model: BuyAssetViewModel(
                                assetAddress: selectType.assetAddress,
                                input: .default
                            )
                        )
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(Localized.Common.done) {
                                    isPresentingAssetSelectType = nil
                                }.bold()
                            }
                        }
                    case .swap:
                        SwapScene(
                            model: SwapViewModel(
                                wallet: model.wallet,
                                assetId: selectType.asset.id,
                                walletsService: walletsService,
                                swapService: SwapService(nodeProvider: nodeService),
                                keystore: keystore
                            )
                        )
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(Localized.Common.done) {
                                    isPresentingAssetSelectType = nil
                                }.bold()
                            }
                        }
                    case .stake:
                        StakeNavigationView(
                            wallet: model.wallet,
                            assetId: selectType.asset.id
                        )
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(Localized.Common.done) {
                                    isPresentingAssetSelectType = nil
                                }.bold()
                            }
                        }
                    case .manage, .priceAlert:
                        EmptyView()
                    }
                }
            }
        }
        .environment(\.isWalletsPresented, $isWalletsPresented)
    }
}

//#Preview {
//    WalletNavigationStack()
//}
