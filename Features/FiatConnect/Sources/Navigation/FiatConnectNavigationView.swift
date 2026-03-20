// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Store
import Components
import Localization
import Style

public struct FiatConnectNavigationView: View {
    @State private var model: FiatSceneViewModel

    public init(model: FiatSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        FiatScene(
            model: model
        )
        .onChangeBindQuery(model.assetQuery, action: model.onAssetDataChange)
        .ifElse(
            model.showFiatTypePicker,
            ifContent: {
                $0.toolbar {
                    FiatTypeToolbar(selectedType: $model.type)
                }
            },
            elseContent: {
                $0.navigationTitle(model.title)
            }
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: Scenes.FiatTransactions(asset: model.asset)) {
                    Images.Tabs.activity
                }
            }
        }
        .navigationDestination(for: Scenes.FiatTransactions.self) {
            FiatTransactionsScene(
                model: FiatTransactionsViewModel(
                    walletId: model.walletId,
                    asset: $0.asset,
                    service: model.fiatTransactionService
                )
            )
        }
        .navigationDestination(for: Scenes.FiatTransaction.self) {
            FiatTransactionDetailScene(
                model: FiatTransactionDetailViewModel(
                    transaction: $0.transaction,
                    walletId: $0.walletId,
                    asset: $0.asset
                )
            )
        }
        .sheet(isPresented: $model.isPresentingFiatProvider) {
            SelectableListNavigationStack(
                model: model.fiatProviderViewModel,
                onFinishSelection: model.onSelectQuotes,
                listContent: { SimpleListItemView(model: $0) }
            )
        }
    }
}
