// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components

struct NetworkSelectorNavigationStack: View {
    let chains: [Chain]
    @Binding var selectedChain: Chain
    @Binding var isPresenting: Bool

    @State private var searchQuery = ""

    var action: ((String) -> Void)?

    var filteredChains: [Chain] {
        chains.filter { chain in
            searchQuery.isEmpty || chain.rawValue.lowercased().contains(searchQuery.lowercased())
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if !filteredChains.isEmpty {
                    List {
                        ForEach(filteredChains) { chain in
                            NavigationCustomLink(with: ChainView(chain: chain)) {
                                onSelect(chain: chain)
                            }
                        }
                    }
                } else {
                    ContentUnavailableView {
                        Text("No data")
                    }
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
