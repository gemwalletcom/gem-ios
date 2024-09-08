// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives

struct WalletNavigationStack: View {
    
    @State private var isWalletsPresented = false
    @State private var isPresentingCreateWalletSheet = false
    @State private var isPresentingImportWalletSheet = false
    @State private var isPresentingAssetSelectType: SelectAssetInput?

    @Environment(\.keystore) private var keystore
    @Environment(\.walletService) private var walletService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.nodeService) private var nodeService
    @Environment(\.stakeService) private var stakeService

    let model: WalletSceneViewModel
    @Binding var navigationPath: NavigationPath
    @State private var navigationPathSelect = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            WalletScene(model: model)
            .sheet(isPresented: $isWalletsPresented) {
                WalletsNavigationStack()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Scenes.Asset.self) { asset in
                AssetNavigationFlow(
                    wallet: model.wallet,
                    assetId: asset.asset.id,
                    isPresentingAssetSelectType: $isPresentingAssetSelectType,
                    navigationPath: $navigationPath
                )
            }
            .navigationDestination(for: TransactionExtended.self) { transaction in
                TransactionScene(
                    input: TransactionSceneInput(transactionId: transaction.id, walletId: model.wallet.walletId)
                )
            }
            .navigationDestination(for: Scenes.Stake.self) {
                StakeNavigationFlow(wallet: $0.wallet, assetId: $0.chain.assetId)
            }
            .navigationDestination(for: Scenes.Price.self) { scene in
                ChartScene(
                    model: ChartsViewModel(
                        walletId: model.wallet.walletId,
                        priceService: walletsService.priceService,
                        assetsService: walletsService.assetsService,
                        assetModel: AssetViewModel(asset: scene.asset)
                    )
                )
            }
            .sheet(item: $isPresentingAssetSelectType) { selectType in
                NavigationStack {
                    switch selectType.type {
                    case .send:
                        AmountNavigationFlow(
                            input: AmountInput(type: .transfer, asset: selectType.asset),
                            wallet: model.wallet,
                            navigationPath: $navigationPathSelect
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
                        StakeNavigationFlow(
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
                    case .manage, .hidden:
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
