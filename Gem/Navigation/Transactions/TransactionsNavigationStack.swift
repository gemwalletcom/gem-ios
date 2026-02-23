// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Style
import Components
import Transactions
import Store
import Assets
import AssetsService

struct TransactionsNavigationStack: View {
    @Environment(\.navigationState) private var navigationState
    @Environment(\.walletsService) private var walletsService
    @Environment(\.priceAlertService) private var priceAlertService
    @Environment(\.activityService) private var activityService
    @Environment(\.assetSearchService) private var assetSearchService
    @Environment(\.contactService) private var contactService

    @State private var model: TransactionsViewModel

    init(model: TransactionsViewModel) {
        _model = State(wrappedValue: model)
    }

    private var navigationPath: Binding<NavigationPath> {
        navigationState.activity.binding
    }

    var body: some View {
        NavigationStack(path: navigationPath) {
            TransactionsScene(model: model)
                .bindQuery(model.filterModel.query)
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
                .navigationDestination(for: Scenes.Transaction.self) {
                    TransactionNavigationView(
                        model: TransactionSceneViewModel(
                            transaction: $0.transaction,
                            walletId: model.wallet.walletId,
                            contactService: contactService
                        )
                    )
                }
                .sheet(isPresented: $model.isPresentingFilteringView) {
                    NavigationStack {
                        TransactionsFilterScene(model: $model.filterModel)
                    }
                    .presentationDetentsForCurrentDeviceSize(expandable: true)
                    .presentationDragIndicator(.visible)
                    .presentationBackground(Colors.grayBackground)
                }
                .sheet(item: $model.isPresentingSelectAssetType) {
                    SelectAssetSceneNavigationStack(
                        model: SelectAssetViewModel(
                            wallet: model.wallet,
                            selectType: $0,
                            searchService: assetSearchService,
                            walletsService: walletsService,
                            priceAlertService: priceAlertService,
                            activityService: activityService
                        ),
                        isPresentingSelectType: $model.isPresentingSelectAssetType
                    )
                }
        }
    }
}
