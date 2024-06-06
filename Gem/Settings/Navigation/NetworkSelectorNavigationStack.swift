// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Settings
import Primitives
import Components

struct NetworkSelectorNavigationStack: View {
    let chains: [Chain]
    @Binding var selectedChain: Chain
    @Binding var isPresenting: Bool

    @State private var searchQuery = ""

    var action: ((String) -> Void)?

    var filteredChains: [Chain] {
        guard !searchQuery.isEmpty else {
            return chains
        }
        return chains.filter {
            $0.asset.name.localizedCaseInsensitiveContains(searchQuery) ||
            $0.asset.symbol.localizedCaseInsensitiveContains(searchQuery) ||
            $0.rawValue.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredChains) { chain in
                    NavigationCustomLink(with: ChainView(chain: chain)) {
                        onSelect(chain: chain)
                    }
                }
            }
            .overlay {
                if filteredChains.isEmpty {
                    StateEmptyView(message: "Localized.Settings.Networks.noChainsFound", image: Image(systemName: SystemImage.searchNoResults))
                }
            }
            .navigationTitle(Localized.Settings.Networks.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Localized.Common.cancel) {
                        onCancel()
                    }
                }
            }
            .searchable(
                text: $searchQuery,
                placement: .navigationBarDrawer(displayMode: .always)
            )
            .autocorrectionDisabled(true)
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

// MARK: - Actions

extension NetworkSelectorNavigationStack {
    private func onSelect(chain: Chain) {
        selectedChain = chain
        $isPresenting.wrappedValue = false
    }

    private func onCancel() {
        $isPresenting.wrappedValue = false
    }
}

// MARK: - Previews

#Preview {
    var mockChains = AssetConfiguration.supportedChainsWithTokens
    @State var selectedChain: Chain = .smartChain
    @State var isPresenting: Bool = false

    return NetworkSelectorNavigationStack(chains: mockChains, selectedChain: $selectedChain, isPresenting: $isPresenting)
}
