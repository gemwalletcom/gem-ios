// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Store
import Style
import Primitives
import Components

struct AssetsFilterScene: View {
    @Environment(\.dismiss) var dismiss
    @Binding var model: AssetsFilterViewModel

    @State private var isPresentingChains: Bool = false

    init(model: Binding<AssetsFilterViewModel>) {
        _model = model
    }

    var body: some View {
        List {
            NavigationCustomLink(
                with: ListItemView(
                    title: model.chainsFilterModel.title,
                    subtitle: model.chainsFilterModel.value,
                    image: model.chainsFilterModel.chainsImage
                ),
                action: onSelectChainsFilter
            )
        }
        .listStyle(.insetGrouped)
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if model.isCusomFilteringSpecified {
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
                chains: model.allChains,
                selectedChains: model.selectedChains,
                onFinishSelection: onFinishSelection(chains:)
            )
        }
    }
}

// MARK: - Actions

extension AssetsFilterScene {
    private func onSelectClear() {
        // clean to default, extend with different filters
        model.selectedChains = []
    }

    private func onSelectDone() {
        dismiss()
    }

    private func onFinishSelection(chains: [Chain]) {
        model.selectedChains = chains
    }

    private func onSelectChainsFilter() {
        isPresentingChains.toggle()
    }
}

#Preview {
    NavigationStack {
        AssetsFilterScene(model: .constant(.init(wallet: .main, type: .buy)))
    }
}
