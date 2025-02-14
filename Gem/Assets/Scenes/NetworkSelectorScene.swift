// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import PrimitivesComponents

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
        SearchableSelectableListView(
            model: $model,
            onFinishSelection: { value in
                onFinishSelection?(value)
                dismiss()
            },
            listContent: { ChainView(model: ChainViewModel(chain: $0)) }
        )
        .navigationTitle(model.title)
    }
}

// MARK: - Previews

#Preview {
    NetworkSelectorScene(
        model: .constant(NetworkSelectorViewModel(items: [.aptos, .arbitrum, .base]))
    )
}
