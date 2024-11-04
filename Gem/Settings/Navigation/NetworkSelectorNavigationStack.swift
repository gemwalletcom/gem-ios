// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Settings
import Primitives
import Components
import Style

struct NetworkSelectorNavigationStack: View {
    @Environment(\.dismiss) var dismiss

    @State private var model: NetworkSelectorViewModel

    private var onFinishSelection: (([Chain]) -> Void)?

    init(chains: [Chain], onFinishSelection: @escaping (([Chain]) -> Void)) {
        _model = State(initialValue: NetworkSelectorViewModel(chains: chains))
        self.onFinishSelection = onFinishSelection
    }

    init(chains: [Chain], selectedChains: [Chain], onFinishSelection: @escaping (([Chain]) -> Void)) {
        _model = State(initialValue: NetworkSelectorViewModel(
            chains: chains,
            selectedChains: selectedChains,
            isMultiSelectionEnabled: true)
        )
        self.onFinishSelection = onFinishSelection
    }

    var body: some View {
        NavigationStack {
            NetworkSelectorScene(model: $model)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if model.isMultiSelectionEnabled && !model.selectedChains.isEmpty {
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

                if model.isMultiSelectionEnabled {
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
    private func onCancel() {
        dismiss()
    }

    private func onDone() {
        onFinishSelection?(Array(model.selectedChains))
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
