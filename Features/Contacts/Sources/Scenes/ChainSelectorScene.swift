// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import PrimitivesComponents
import Components
import Localization

struct ChainSelectorScene: View {

    @State private var model: NetworkSelectorViewModel

    private let onSelectChain: (Chain) -> Void

    init(chain: Chain?, onSelectChain: @escaping (Chain) -> Void) {
        _model = State(initialValue: NetworkSelectorViewModel(
            state: .data(.plain(Chain.allCases)),
            selectedItems: [chain].compactMap { $0 },
            selectionType: .checkmark
        ))
        self.onSelectChain = onSelectChain
    }

    var body: some View {
        SearchableSelectableListView(
            model: $model,
            onFinishSelection: { chains in
                if let chain = chains.first {
                    onSelectChain(chain)
                }
            },
            listContent: { ChainView(model: ChainViewModel(chain: $0)) }
        )
        .navigationTitle(Localized.Transfer.network)
    }
}
