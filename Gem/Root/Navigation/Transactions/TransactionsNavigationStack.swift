// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Style
import Components
import Transactions
import Store

struct TransactionsNavigationStack: View {
    @Environment(\.navigationState) private var navigationState
    @Environment(\.walletsService) private var walletsService
    @Environment(\.priceAlertService) private var priceAlertService

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
                    AssetScene(
                        wallet: model.wallet,
                        input: AssetSceneInput(walletId: model.walletId, assetId: $0.asset.id),
                        isPresentingAssetSelectedInput: Binding.constant(.none),
                        onAssetActivate: .none
                    )
                }
                .sheet(isPresented: $model.isPresentingFilteringView) {
                    NavigationStack {
                        TransactionsFilterScene(model: $model.filterModel)
                    }
                    .presentationDetents([.medium])
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
