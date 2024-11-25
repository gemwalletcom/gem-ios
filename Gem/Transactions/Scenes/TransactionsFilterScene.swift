// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Primitives

struct TransactionsFilterScene: View {
    @Environment(\.dismiss) var dismiss
    @Binding var model: TransactionsFilterViewModel

    @State private var isPresentingChains: Bool = false

    init(model: Binding<TransactionsFilterViewModel>) {
        _model = model
    }

    var body: some View {
        List {
            SelectChainView(
                typeModel: model.chainsFilter.typeModel,
                action: onSelectChainsFilter)
        }
        .listStyle(.insetGrouped)
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if model.isAnyFilterSpecified {
                ToolbarItem(placement: .cancellationAction) {
                    Button(model.clear, action: onSelectClear)
                        .bold()
                        .buttonStyle(.plain)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button(model.done, action: onSelectDone)
                    .bold()
                    .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $isPresentingChains) {
            NetworkSelectorNavigationStack(
                chains: model.chainsFilter.allChains,
                selectedChains: model.chainsFilter.selectedChains,
                isMultiSelectionEnabled: true,
                onFinishSelection: onFinishSelection(chains:)
            )
        }
    }
}

// MARK: - Actions

extension TransactionsFilterScene {
    private func onSelectClear() {
        model.chainsFilter.selectedChains = []
    }

    private func onSelectDone() {
        dismiss()
    }

    private func onFinishSelection(chains: [Chain]) {
        model.chainsFilter.selectedChains = chains
    }

    private func onSelectChainsFilter() {
        isPresentingChains.toggle()
    }
}

#Preview {
    NavigationStack {
        TransactionsFilterScene(
            model:.constant(
                TransactionsFilterViewModel(
                    model: ChainsFilterViewModel(
                        allChains: [.aptos, .arbitrum],
                        selectedChains: []
                    )
                )
            )
        )
    }
}
