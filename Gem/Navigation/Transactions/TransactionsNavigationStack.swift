// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Style
import Components
import Transactions
import Store
import Assets
import Swap

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
                    request: $model.request,
                    value: $model.transactions
                )
                .onChange(of: model.filterModel, model.onChangeFilter)
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
                    TransactionScene(
                        input: TransactionSceneInput(
                            transactionId: $0.id,
                            walletId: model.walletId
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
                            isPresentingAssetSelectedInput: .constant(.none)
                        )
                    )
                }
                .sheet(isPresented: $model.isPresentingFilteringView) {
                    NavigationStack {
                        TransactionsFilterScene(model: model.filterModel)
                    }
                    .presentationDetentsForCurrentDeviceSize(expandable: true)
                    .presentationDragIndicator(.visible)
                }
                .sheet(item: $model.isPresentingSelectAssetType) {
                    SelectAssetSceneNavigationStack(
                        model: SelectAssetViewModel(
                            wallet: model.wallet,
                            selectType: $0,
                            assetsService: walletsService.assetsService,
                            walletsService: walletsService,
                            priceAlertService: priceAlertService
                        ),
                        isPresentingSelectType: $model.isPresentingSelectAssetType
                    )
                }
        }
    }
}
