// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives

struct NetworkSelectorScene: View {
    @Environment(\.dismiss) var dismiss

    @Binding var model: NetworkSelectorViewModel

    private var onFinishSelection: (([Chain]) -> Void)?

    init(model: Binding<NetworkSelectorViewModel>,
         onFinishSelection: (([Chain]) -> Void)? = nil) {
        _model = model
        self.onFinishSelection = onFinishSelection
    }

    var body: some View {
        SearchableListView(
            items: model.chains,
            filter: model.filter(_:query:),
            content: { chain in
                if model.isMultiSelectionEnabled {
                    SelectionView(
                        value: chain,
                        selection: model.selectedChains.contains(chain) ? chain : nil,
                        action: onSelect(chain:),
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
                    title: model.noResultsTitle,
                    image: model.noResultsImage
                )
            }
        )
        .navigationTitle(model.title)
    }
}

// MARK: - Actions

extension NetworkSelectorScene {
    private func onSelect(chain: Chain) {
        model.toggle(chain: chain)

        guard !model.isMultiSelectionEnabled else { return }
        onFinishSelection?(Array(model.selectedChains))
        dismiss()
    }
}

// MARK: - Previews

#Preview {
    NetworkSelectorScene(
        model: .constant(NetworkSelectorViewModel(chains: [.aptos, .arbitrum, .base]))
    )
}
