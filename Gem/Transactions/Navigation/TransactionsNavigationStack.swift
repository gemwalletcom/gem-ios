// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Style
import Components

struct TransactionsNavigationStack: View {
    @Environment(\.navigationState) private var navigationState

    @State private var isPresentingFilteringView: Bool = false
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
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        FilterButton(
                            isActive: model.filterModel.isAnyFilterSpecified,
                            action: onSelectFilter)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(model.title)
                .navigationDestination(for: TransactionExtended.self) {
                    TransactionScene(
                        input: TransactionSceneInput(transactionId: $0.id, walletId: model.walletId)
                    )
                }
                .navigationDestination(for: Scenes.Asset.self) {
                    AssetScene(
                        wallet: model.wallet,
                        input: AssetSceneInput(walletId: model.walletId, assetId: $0.asset.id),
                        isPresentingAssetSelectType: Binding.constant(.none)
                    )
                }
        }
        .sheet(isPresented: $isPresentingFilteringView) {
            NavigationStack {
                TransactionsFilterScene(model: $model.filterModel)
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Actions

extension TransactionsNavigationStack {
    private func onSelectFilter() {
        isPresentingFilteringView.toggle()
    }
}
