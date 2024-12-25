// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Store
import Style
import Primitives
import Components
import PrimitivesComponents

struct AssetsFilterScene: View {
    @Environment(\.dismiss) var dismiss
    @Binding var model: AssetsFilterViewModel

    @State private var isPresentingChains: Bool = false

    init(model: Binding<AssetsFilterViewModel>) {
        _model = model
    }

    var body: some View {
        List {
            SelectFilterView(
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
            SelectableSheet(
                model: model.networksModel,
                onFinishSelection: onFinishSelection(chains:),
                listContent: { ChainView(model: ChainViewModel(chain: $0))}
            )
        }
    }
}

// MARK: - Actions

extension AssetsFilterScene {
    private func onSelectClear() {
        // clean to default, extend with different filters
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
        AssetsFilterScene(
            model: .constant(
                AssetsFilterViewModel(
                    type: .manage,
                    model: ChainsFilterViewModel(chains: [.arbitrum, .avalancheC, .base])
                )
            )
        )
    }
}
