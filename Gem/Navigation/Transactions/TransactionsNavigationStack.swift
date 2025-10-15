// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Style
import Components
import Transactions
import Store
import Assets
import AssetsService
import SwapService

struct TransactionsNavigationStack: View {
    @Environment(\.navigationState) private var navigationState
    @Environment(\.walletsService) private var walletsService
    @Environment(\.priceAlertService) private var priceAlertService

    @Environment(\.assetsService) private var assetsService
    @Environment(\.priceObserverService) private var priceObserverService
    @Environment(\.bannerService) private var bannerService

    @State private var model: TransactionsViewModel

    init(model: TransactionsViewModel) {
        _model = State(wrappedValue: model)
    }

    private var navigationPath: Binding<NavigationPath> {
        Binding(
            get: { navigationState.activity },
            set: { navigationState.activity = $0 }
        )
    }

    var body: some View {
        NavigationStack(path: navigationPath) {
            TransactionsScene(model: model)
                .observeQuery(
                    request: $model.filterModel.request,
                    value: $model.transactions
                )
                .onChange(
                    of: model.currentWallet,
                    initial: true,
                    model.onChangeWallet
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        FilterButton(
                            isActive: model.filterModel.isAnyFilterSpecified,
                            action: model.onSelectFilterButton)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(model.title)
                .navigationDestination(for: TransactionExtended.self) {
                    TransactionNavigationView(
                        model: TransactionSceneViewModel(
                            transaction: $0,
                            walletId: model.wallet.id
                        )
                    )
                }
                .navigationDestination(for: Scenes.Asset.self) {
                    AssetNavigationView(
                        model: AssetSceneViewModel(
                            walletsService: walletsService,
                            assetsService: assetsService,
                            transactionsService: model.transactionsService,
                            priceObserverService: priceObserverService,
                            priceAlertService: priceAlertService,
                            bannerService: bannerService,
                            input: AssetSceneInput(
                                wallet: model.wallet,
                                asset: $0.asset
                            ),
                            isPresentingSelectedAssetInput: .constant(.none)
                        )
                    )
                }
                .sheet(isPresented: $model.isPresentingFilteringView) {
                    NavigationStack {
                        TransactionsFilterScene(model: $model.filterModel)
                    }
                    .presentationDetentsForCurrentDeviceSize(expandable: true)
                    .presentationDragIndicator(.visible)
                }
                .sheet(item: $model.isPresentingSelectAssetType) {
                    SelectAssetSceneNavigationStack(
                        model: SelectAssetViewModel(
                            wallet: model.wallet,
                            selectType: $0,
                            searchService: AssetSearchService(assetsService: assetsService),
                            walletsService: walletsService,
                            priceAlertService: priceAlertService
                        ),
                        isPresentingSelectType: $model.isPresentingSelectAssetType
                    )
                }
        }
    }
}
