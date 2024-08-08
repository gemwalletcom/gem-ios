// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Settings
import Keystore
import Store
import GRDBQuery
import Style

struct WalletScene: View {
    
    @Environment(\.db) private var DB
    @Environment(\.keystore) private var keystore
    @Environment(\.assetsService) private var assetsService
    @Environment(\.transactionsService) private var transactionsService
    @Environment(\.connectionsService) private var connectionsService
    @Environment(\.walletService) private var walletService
    @Environment(\.isWalletsPresented) private var isWalletsPresented
    @Environment(\.nodeService) private var nodeService
    
    @Query<TotalValueRequest>
    private var fiatValue: WalletFiatValue

    @Query<AssetsRequest>
    private var assets: [AssetData]

    @Query<TransactionsRequest>
    private var transactions: [Primitives.TransactionExtended]

    @Query<WalletRequest>
    var dbWallet: Wallet?

    @State private var isPresentingSelectType: SelectAssetType? = nil
    @State private var isPresentingAssetSelectType: SelectAssetInput? = nil
    
    let model: WalletSceneViewModel

    public init(
        model: WalletSceneViewModel
    ) {
        self.model = model

        try? model.setupWallet()

        _assets = Query(constant: model.assetsRequest, in: \.db.dbQueue)
        _fiatValue = Query(constant: model.fiatValueRequest, in: \.db.dbQueue)
        _transactions = Query(constant: model.recentTransactionsRequest, in: \.db.dbQueue)
        _dbWallet = Query(constant: model.walletRequest, in: \.db.dbQueue)
    }
    
    var body: some View {
        List {
            WalletHeaderView(
                model: WalletHeaderViewModel(walletType: model.wallet.type, value: fiatValue)
            ) {
                isPresentingSelectType = $0.selectType
            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(Color.red)

            Section {
                WalletAssetsList(
                    assets: assets,
                    copyAssetAddress: { address in
                        model.copyAssetAddress(for: address)
                    },
                    hideAsset: { assetId in
                        Task { try model.hideAsset(assetId) }
                    }
                )
            } footer: {
                ListButton(
                    title: Localized.Wallet.manageTokenList,
                    //image: Image(systemName: SystemImage.checklist),
                    image: Image(.manageAssets),
                    action: {
                        isPresentingSelectType = .manage
                    }
                )
                .accessibilityIdentifier("manage")
                .padding(Spacing.medium)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .contentMargins(.top, .zero)
        .refreshable {
            await refreshable()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                if let wallet = dbWallet {
                    HStack {
                        WalletBarView(
                            model: WalletBarViewViewModel.from(wallet: wallet, showChevron: true)
                        ) {
                            isWalletsPresented.wrappedValue.toggle()
                        }
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isPresentingSelectType = .manage
                } label: {
                    Image(.manageAssets)
                }
            }
        }
        .sheet(item: $isPresentingSelectType) { value in
            SelectAssetSceneNavigationStack(
                model: SelectAssetViewModel(
                    wallet: model.wallet,
                    keystore: keystore,
                    selectType: value,
                    assetsService: assetsService,
                    walletService: walletService
                ),
                isPresenting: $isPresentingSelectType
            )
        }
        .sheet(item: $isPresentingAssetSelectType) { selectType in
            NavigationStack {
                switch selectType.type {
                case .send:
                    RecipientScene(
                        model: RecipientViewModel(
                            wallet: model.wallet,
                            keystore: keystore,
                            walletService: walletService,
                            assetModel: AssetViewModel(asset: selectType.asset)
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
                    .navigationBarTitleDisplayMode(.inline)
                case .receive:
                    ReceiveScene(
                        model: ReceiveViewModel(
                            assetModel: AssetViewModel(asset: selectType.asset),
                            walletId: model.wallet.walletId,
                            address: selectType.address,
                            walletService: walletService
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
                            walletService: walletService,
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
                    StakeScene(model: StakeViewModel(wallet: model.wallet, chain: selectType.asset.id.chain, stakeService: walletService.stakeService))
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
        .navigationDestination(for: TransactionExtended.self) { transaction in
            TransactionScene(
                input: TransactionSceneInput(transactionId: transaction.id, walletId: model.wallet.walletId)
            )
        }
        .navigationDestination(for: AssetData.self) { assetData in
            AssetScene(
                wallet: model.wallet,
                input: AssetSceneInput(walletId: model.wallet.walletId, assetId: assetData.asset.id),
                isPresentingAssetSelectType: $isPresentingAssetSelectType
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: model.wallet, fetch)
        .taskOnce(fetch)
    }
    
    func refreshable() async {
        if let walletId = keystore.currentWalletId {
            Task {
                try await model.fetch(walletId: walletId, assets: assets)
            }
        }
    }

    func fetch() {
        Task {
            do {
                try await model.fetch(assets: assets)
            } catch {
                NSLog("fetch error: \(error)")
            }
        }
    }
}
