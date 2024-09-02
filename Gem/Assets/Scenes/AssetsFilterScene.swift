// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Store
import Style
import Primitives

struct AssetsFilterScene: View {
    @Environment(\.dismiss) var dismiss
    @Binding var model: AssetsFilterViewModel

    @State private var isPresentingChains: Bool = false

    init(model: Binding<AssetsFilterViewModel>) {
        _model = model
    }

    var body: some View {
        VStack {
            HStack {
                Button(action: onSelectChainsFilter) {
                    HStack {
                        Text(model.chainsFilterModel.title)
                        Image(systemName: SystemImage.chevronDown)
                    }
                    .font(.body)
                    .foregroundStyle(model.chainsFilterModel.type == ChainsFilterType.primary ? .black : .white)
                    .padding(.horizontal, Spacing.tiny + Spacing.small)
                    .padding(.vertical, Spacing.tiny)
                    .background(
                        Capsule()
                            .fill(model.chainsFilterModel.type == ChainsFilterType.primary ? .white : Colors.blue)
                            .if(model.chainsFilterModel.type == ChainsFilterType.primary) {
                                $0.stroke(Color.gray.opacity(0.33), lineWidth: 0.66)
                            }
                    )
                }
                .buttonStyle(.plain)
                Spacer()
            }
            Divider()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
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
                onSelectMultipleChains: onSelectMultiple(chains:)
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

    private func onSelectMultiple(chains: [Chain]) {
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
