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
    
    @Query<TotalValueRequest>
    var fiatValue: WalletFiatValue
    
    @Query<AssetsRequest>
    var assets: [AssetData]
    
    @Query<TransactionsRequest>
    var transactions: [Primitives.TransactionExtended]
    
    @State private var isPresentingSelectType: SelectAssetType? = nil
    @State private var isPresentingAssetSelectType: SelectAssetInput? = nil
    
    @State var wallet: Wallet
    let model: WalletSceneViewModel
    
    public init(
        wallet: Wallet,
        model: WalletSceneViewModel
    ) {
        self.wallet = wallet
        self.model = model
        try? model.setupWallet(wallet)
        
        _assets = Query(constant: AssetsRequest(walletID: wallet.id, chains: [], filters: [.enabled]), in: \.db.dbQueue)
        _fiatValue = Query(constant: TotalValueRequest(walletID: wallet.id), in: \.db.dbQueue)
        _transactions = Query(constant: TransactionsRequest(walletId: wallet.id, type: .pending, limit: 3), in: \.db.dbQueue)
    }
    
    var body: some View {
        List {
            Section { } header: {
                WalletHeaderView(
                    model: WalletHeaderViewModel(walletModel: WalletViewModel(wallet: wallet), value: fiatValue)
                ) {
                    isPresentingSelectType = $0.selectType
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
            .textCase(nil)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            
            TransactionsList(transactions)
            
            Section {
                WalletAssetsList(
                    assets: assets,
                    copyAssetAddress: { address in
                        model.copyAssetAddress(for: address)
                    },
                    hideAsset: { assetId in
                        Task { try model.hideAsset(for: wallet, assetId) }
                    }
                )
            }
            footer: {
                ListButton(
                    title: Localized.Wallet.manageTokenList,
                    //image: Image(systemName: SystemImage.checklist),
                    image: Image(.manageAssets),
                    action: {
                        isPresentingSelectType = .manage
                    }
                )
                .accessibilityIdentifier("manage")
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .refreshable {
            NSLog("wallet refreshable \(wallet.name)")
            Task {
                await fetch(for: wallet)
            }
        }
        .sheet(item: $isPresentingSelectType) { value in
            SelectAssetSceneNavigationStack(
                model: SelectAssetViewModel(
                    wallet: wallet,
                    keystore: keystore,
                    selectType: value,
                    assetsService: assetsService,
                    walletService: walletService
                ), 
                isPresenting: $isPresentingSelectType
            )
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    WalletBarView(
                        model: WalletBarViewViewModel(
                            name: WalletViewModel(wallet: wallet).name,
                            image: WalletViewModel(wallet: wallet).assetImage,
                            showChevron: true
                        )
                    ) {
                        isWalletsPresented.wrappedValue.toggle()
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isPresentingSelectType = .manage
                } label: {
                    //Image(systemName: SystemImage.checklist)
                    Image(.manageAssets)
                }
            }
        }
        .sheet(item: $isPresentingAssetSelectType) { selectType in
            NavigationStack {
                switch selectType.type {
                case .send:
                    RecipientScene(
                        model: RecipientViewModel(
                            wallet: wallet,
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
                            wallet: wallet,
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
                    SwapScene(model: SwapViewModel(wallet: wallet, keystore: keystore, walletService: walletService, assetId: selectType.asset.id))
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(Localized.Common.done) {
                                    isPresentingAssetSelectType = nil
                                }.bold()
                            }
                        }
                case .stake:
                    StakeScene(model: StakeViewModel(wallet: wallet, chain: selectType.asset.id.chain, service: walletService.stakeService))
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
                input: TransactionSceneInput(transactionId: transaction.id, wallet: wallet)
            )
        }
        .navigationDestination(for: AssetData.self) { assetData in
            AssetScene(
                input: AssetSceneInput(assetId: assetData.asset.id, wallet: wallet),
                isPresentingAssetSelectType: $isPresentingAssetSelectType
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: wallet) {
            Task {
                await fetch(for: wallet)
            }
        }
        .onChange(of: keystore.currentWallet) {
            if let newValue = keystore.currentWallet {
                wallet = newValue
            }
        }.taskOnce {
            Task {
                await fetch(for: wallet)
            }
        }
    }
    
    func fetch(for wallet: Wallet) async  {
        NSLog("fetch for: \(wallet.name)")
        do {
            let assetIds = assets.map { $0.asset.id }
            try await model.fetch(for: wallet, assetIds: assetIds)
        } catch {
            NSLog("fetch error: \(error)")
        }
    }
}
