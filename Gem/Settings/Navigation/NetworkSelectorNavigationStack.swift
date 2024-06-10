// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Settings
import Primitives
import Components
import Style

struct NetworkSelectorNavigationStack: View {
    let model: NetworkSelectorViewModel

    @Binding var isPresenting: Bool

    var onSelectChain: (Chain) -> Void

    var body: some View {
        NavigationStack {
            SearchableListView(
                items: model.chains,
                filter: model.filter(_:query:),
                content: { chain in
                    NavigationCustomLink(with: ChainView(chain: chain)) {
                        onSelect(chain: chain)
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Localized.Common.cancel) {
                        onCancel()
                    }
                }
            }
        }
    }
}

// MARK: - Actions

extension NetworkSelectorNavigationStack {
    private func onSelect(chain: Chain) {
        onSelectChain(chain)
        $isPresenting.wrappedValue = false
    }

    private func onCancel() {
        $isPresenting.wrappedValue = false
    }
}

// MARK: - Previews

#Preview {
    var mockChains = Chain.allCases
    @State var selectedChain: Chain = .smartChain
    @State var isPresenting: Bool = false

    return NetworkSelectorNavigationStack(model: .init(chains: mockChains, selectedChain: .ethereum), isPresenting: $isPresenting) { _ in
        
    }
}
