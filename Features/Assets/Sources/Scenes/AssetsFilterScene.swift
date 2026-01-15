// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Store
import Style
import Primitives
import Components
import PrimitivesComponents

public struct AssetsFilterScene: View {
    @Environment(\.dismiss) var dismiss
    @Binding var model: AssetsFilterViewModel

    @State private var isPresentingChains: Bool = false

    public init(model: Binding<AssetsFilterViewModel>) {
        _model = model
    }

    public var body: some View {
        List {
            SelectFilterView(
                typeModel: model.chainsFilter.typeModel,
                action: onSelectChainsFilter)

            if model.showHasBalanceToggle {
                ListItemToggleView(
                    isOn: $model.hasBalance,
                    title: model.hasBalanceTitle,
                    imageStyle: model.hasBalanceImageStyle
                )
            }
        }
        .contentMargins(.top, .scene.top, for: .scrollContent)
        .listStyle(.insetGrouped)
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if model.isAnyFilterSpecified {
                ToolbarItem(placement: .cancellationAction) {
                    Button(model.clear, action: onSelectClear)
                        .bold()
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button(model.done, action: onSelectDone)
                    .bold()
            }
        }
        .sheet(isPresented: $isPresentingChains) {
            SelectableSheet(
                model: model.networksModel,
                onFinishSelection: onFinishSelection(value:),
                listContent: { ChainView(model: ChainViewModel(chain: $0))}
            )
        }
    }
}

// MARK: - Actions

extension AssetsFilterScene {
    private func onSelectClear() {
        model.chainsFilter.selectedChains = []
        model.hasBalance = false
    }

    private func onSelectDone() {
        dismiss()
    }

    private func onFinishSelection(value: SelectionResult<Chain>) {
        model.chainsFilter.selectedChains = value.items
        if value.isConfirmed {
            dismiss()
        }
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
