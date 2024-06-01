// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import GRDB
import GRDBQuery
import Store
import Style

struct AssetScene: View {
    
    private let input: AssetSceneInput
    var action: HeaderButtonAction?
    @Binding var isPresentingAssetSelectType: SelectAssetInput?
    @State var isPresentingStaking: Bool = false
    
    private var model: AssetSceneViewModel {
        return AssetSceneViewModel(
            assetsService: assetsService,
            transactionsService: transactionsService,
            stakeService: stakeService,
            assetDataModel: AssetDataViewModel(assetData: assetData, formatter: .medium),
            walletModel: WalletViewModel(wallet: input.wallet)
        )
    }
    
    @State private var showingOptions = false
    
    @Environment(\.walletService) private var walletService
    @Environment(\.assetsService) private var assetsService
    @Environment(\.transactionsService) private var transactionsService
    @Environment(\.stakeService) private var stakeService
    
    @Query<TransactionsRequest>
    var transactions: [TransactionExtended]
    
    @Query<AssetRequest>
    var assetData: AssetData
    
    init(
        input: AssetSceneInput,
        isPresentingAssetSelectType: Binding<SelectAssetInput?>
    ) {
        self.input = input
        _isPresentingAssetSelectType = isPresentingAssetSelectType
        _assetData = Query(constant: input.assetRequest, in: \.db.dbQueue)
        _transactions = Query(constant: input.transactionsRequest, in: \.db.dbQueue)
    }
    
    var body: some View {
        List {
            Section { } header: {
                WalletHeaderView(model: model.headerViewModel) {
                    isPresentingAssetSelectType = SelectAssetInput(type: $0.selectType, assetAddress: assetData.assetAddress)
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
            .textCase(nil)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            
            Section {
                if model.showPriceView {
                    NavigationLink(value: model.assetModel.asset) {
                        HStack {
                            ListItemView(title: Localized.Asset.price)
                                .accessibilityIdentifier("price")
                            Spacer()
                            HStack(spacing: 4) {
                                Text(model.priceView.text)
                                    .font(model.priceView.style.font)
                                    .foregroundColor(model.priceView.style.color)
                                Text(model.priceChangeView.text)
                                    .font(model.priceChangeView.style.font)
                                    .foregroundColor(model.priceChangeView.style.color)
                            }
                        }
                    }
                }
                if model.showNetwork {
                    HStack {
                        ListItemView(title: model.networkField, subtitle: model.networkText)
                        AssetImageView(assetImage: model.networkAssetImage, size: Sizing.list.image)
                    }
                }
            }
            
            if model.showBalances {
                Section(Localized.Asset.balances) {
                    ListItemView(title: Localized.Asset.Balances.available, subtitle: model.assetDataModel.availableBalanceTextWithSymbol)
                    if model.showStakedBalance {
                        NavigationCustomLink(
                            with: ListItemView(title: Localized.Wallet.stake, subtitle: model.assetDataModel.stakeBalanceTextWithSymbol)) {
                                isPresentingStaking.toggle()
                            }
                    }
                    if model.showReservedBalance, let url = model.reservedBalanceUrl {
                        NavigationCustomLink(with: ListItemView(title: Localized.Asset.Balances.reserved, subtitle: model.assetDataModel.reservedBalanceTextWithSymbol)) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            } else if model.assetDataModel.isStakeEnabled {
                NavigationCustomLink(
                    with: ListItemView(title: Localized.Transfer.Stake.title, subtitle: model.stakeAprText)) {
                        isPresentingStaking.toggle()
                    }
            }
            
            if transactions.count > 0 {
                TransactionsList(transactions)
            }
        }
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                HStack {
//                    AssetTitleView(model: model.headerTitleView)
//                }
//            }
//        }
        .refreshable {
            NSLog("refresh asset \(model.assetModel.asset.name)")
            Task {
                do {
                    try await fetch()
                } catch {
                    NSLog("refresh asset \(model.assetModel.asset.name) failed")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingOptions = true
                } label: {
                    Image(systemName: SystemImage.ellipsis)
                }.confirmationDialog("", isPresented: $showingOptions, titleVisibility: .hidden) {
                    Button(model.viewAddressOnTitle) {
                        UIApplication.shared.open(model.addressExplorerUrl)
                    }
                    if let title = model.viewTokenOnTitle, let url = model.tokenExplorerUrl {
                        Button(title) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
        }
        .navigationDestination(for: Asset.self) { asset in
            ChartScene(model: ChartsViewModel(
                    walletModel: model.walletModel,
                    priceService: walletService.priceService,
                    assetsService: walletService.assetsService,
                    assetModel: AssetViewModel(asset: asset)
                )
            )
        }
        .sheet(isPresented: $isPresentingStaking) {
            NavigationStack {
                StakeScene(
                    model: StakeViewModel(
                        wallet: model.walletModel.wallet,
                        chain: model.assetModel.asset.chain,
                        service: stakeService
                    )
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(Localized.Common.done) {
                            isPresentingStaking.toggle()
                        }
                        .bold()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .taskOnce {
            Task { try await fetch() }
            Task { await model.updateAsset() }
        }
        .navigationTitle(model.title)
    }
    
    func fetch() async throws {
        async let updateAsset: () = try walletService.updateAsset(
            wallet: model.walletModel.wallet,
            assetId: model.assetModel.asset.id
        )
        async let updateTransactions: () = try model.fetchTransactions()
        let _ = try await [updateAsset, updateTransactions]
    }
}

//struct AssetScene_Previews: PreviewProvider {
//    static var previews: some View {
//        AssetScene(
//            model: .from(walletModel: WalletViewModel(wallet: .main), assetData: .main)
//        )
//    }
//}
