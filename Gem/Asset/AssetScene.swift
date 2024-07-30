// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import GRDB
import GRDBQuery
import Store
import Style

struct AssetScene: View {
    @Environment(\.walletService) private var walletService
    @Environment(\.assetsService) private var assetsService
    @Environment(\.transactionsService) private var transactionsService
    @Environment(\.stakeService) private var stakeService

    @State private var isPresentingStaking: Bool = false
    @State private var showingOptions = false

    @Binding private var isPresentingAssetSelectType: SelectAssetInput?

    @Query<TransactionsRequest>
    private var transactions: [TransactionExtended]

    @Query<AssetRequest>
    private var assetData: AssetData

    private let wallet: Wallet
    private let input: AssetSceneInput

    private var model: AssetSceneViewModel {
        return AssetSceneViewModel(
            walletService: walletService,
            assetsService: assetsService,
            transactionsService: transactionsService,
            stakeService: stakeService,
            assetDataModel: AssetDataViewModel(assetData: assetData, formatter: .medium),
            walletModel: WalletViewModel(wallet: wallet)
        )
    }

    init(
        wallet: Wallet,
        input: AssetSceneInput,
        isPresentingAssetSelectType: Binding<SelectAssetInput?>
    ) {
        self.wallet = wallet
        self.input = input
        _isPresentingAssetSelectType = isPresentingAssetSelectType
        _assetData = Query(constant: input.assetRequest, in: \.db.dbQueue)
        _transactions = Query(constant: input.transactionsRequest, in: \.db.dbQueue)
    }

    var body: some View {
        List {
            Section { } header: {
                WalletHeaderView(model: model.headerViewModel, action: onSelectHeader(_:))
                    .padding(.top, Spacing.small)
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
                            HStack(spacing: Spacing.tiny) {
                                Text(model.priceView.text)
                                    .textStyle(model.priceView.style)
                                Text(model.priceChangeView.text)
                                    .textStyle(model.priceChangeView.style)
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
                            with: ListItemView(title: Localized.Wallet.stake, subtitle: model.assetDataModel.stakeBalanceTextWithSymbol),
                            action: onToggleStacking
                        )
                    }

                    if model.showReservedBalance, let url = model.reservedBalanceUrl {
                        NavigationCustomLink(
                            with: ListItemView(title: Localized.Asset.Balances.reserved, subtitle: model.assetDataModel.reservedBalanceTextWithSymbol),
                            action: { onOpenLink(url) }
                        )
                    }
                }
            } else if model.assetDataModel.isStakeEnabled {
                NavigationCustomLink(
                    with: ListItemView(title: Localized.Transfer.Stake.title, subtitle: model.stakeAprText),
                    action: onToggleStacking
                )
            }

            if transactions.count > 0 {
                TransactionsList(transactions)
            } else {
                Section {
                    StateEmptyView(title: Localized.Activity.EmptyState.message)
                }
            }
        }
        .refreshable {
            fetch()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: onSelectOptions) {
                    Image(systemName: SystemImage.ellipsis)
                }
                .confirmationDialog("", isPresented: $showingOptions, titleVisibility: .hidden) {
                    Button(model.viewAddressOnTitle) { onOpenLink(model.addressExplorerUrl )}
                    if let title = model.viewTokenOnTitle, let url = model.tokenExplorerUrl {
                        Button(title) { onOpenLink(url) }
                    }
                }
            }
        }
        .navigationDestination(for: Asset.self) { asset in
            ChartScene(model: ChartsViewModel(
                    walletId: input.walletId,
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
                        wallet: wallet,
                        chain: model.assetModel.asset.chain,
                        stakeService: stakeService
                    )
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(Localized.Common.done, action: onToggleStacking)
                        .bold()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .taskOnce(onTaskOnce)
        .navigationTitle(model.title)
    }
}

// MARK: - Actions

extension AssetScene {
    @MainActor
    private func onSelectHeader(_ buttonType: HeaderButtonType) {
        isPresentingAssetSelectType = SelectAssetInput(type: buttonType.selectType, assetAddress: assetData.assetAddress)
    }

    @MainActor
    private func onToggleStacking() {
        isPresentingStaking.toggle()
    }

    @MainActor
    private func onOpenLink(_ url: URL) {
        // TODO: - find issue why we can't use @Environment(\.openURL) private var openURL here
        // once we add native env url openning, we go to recursion on NavigationLink(value: model.assetModel.asset) { }
        // AssetSceneViewModel recreates infinitly
        guard UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }

    @MainActor
    private func onSelectOptions() {
        showingOptions = true
    }

    private func onTaskOnce() {
        fetch()
        Task { await model.updateAsset() }
    }
}

// MARK: - Effects

extension AssetScene {
    private func fetch() {
        Task {
            await model.updateWallet()
        }
    }
}
