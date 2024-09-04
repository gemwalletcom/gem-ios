// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Settings
import Primitives
import Components
import Style

struct NetworkSelectorNavigationStack: View {
    @Environment (\.dismiss) var dismiss

    @State private var model: NetworkSelectorViewModel

    private var onSelectChain: ((Chain) -> Void)?
    private var onSelectMultipleChains: (([Chain]) -> Void)?

    init(chains: [Chain], onSelectChain: @escaping ((Chain) -> Void)) {
        _model = State(initialValue: NetworkSelectorViewModel(chains: chains, selectedChains: [], isMultipleSelectionEnabled: false))
        self.onSelectChain = onSelectChain
    }

    init(chains: [Chain], selectedChains: [Chain], onSelectMultipleChains: @escaping (([Chain]) -> Void)) {
        _model = State(initialValue: NetworkSelectorViewModel(chains: chains, selectedChains: selectedChains, isMultipleSelectionEnabled: true))
        self.onSelectMultipleChains = onSelectMultipleChains
    }

    var body: some View {
        NavigationStack {
            SearchableListView(
                items: model.chains,
                filter: model.filter(_:query:),
                content: { chain in
                    if model.isMultipleSelectionEnabled {
                        SelectionView(
                            value: chain,
                            selection: model.selectedChains.contains(chain) ? chain : nil,
                            action: onSelectMultiple(chain:),
                            content: {
                                ChainView(chain: chain)
                            }
                        )
                    } else {
                        NavigationCustomLink(with: ChainView(chain: chain)) {
                            onSelect(chain: chain)
                        }
                    }
                },
                emptyContent: {
                    StateEmptyView(
                        title: Localized.Common.noResultsFound,
                        image: Image(systemName: SystemImage.searchNoResults)
                    )
                }
            )
            .navigationTitle(Localized.Settings.Networks.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if model.isMultipleSelectionEnabled && !model.selectedChains.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(model.clearButtonTitle, action: onClear)
                            .bold()
                    }
                } else {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(model.cancelButtonTitle, action: onCancel)
                            .bold()
                    }
                }

                if model.isMultipleSelectionEnabled {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(model.doneButtonTitle) {
                            onDone()
                        }
                        .bold()
                    }
                }
            }
        }
    }
}

// MARK: - Actions

extension NetworkSelectorNavigationStack {
    private func onSelect(chain: Chain) {
        onSelectChain?(chain)
        dismiss()
    }

    private func onSelectMultiple(chain: Chain) {
        model.toggle(chain: chain)
    }

    private func onCancel() {
        dismiss()
    }

    private func onDone() {
        onSelectMultipleChains?(Array(model.selectedChains))
        dismiss()
    }

    private func onClear() {
        model.clean()
    }
}

// MARK: - Previews

#Preview {
    NetworkSelectorNavigationStack(chains: Chain.allCases, selectedChains: [.smartChain]) { _ in }
}
