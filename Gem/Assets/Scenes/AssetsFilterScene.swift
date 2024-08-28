// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Store
import Style

struct AssetsFilterScene: View {
    @Environment(\.dismiss) var dismiss
    @Binding var model: AssetsFilterViewModel

    @State private var isPresentingChains: Bool = false

    init(model: Binding<AssetsFilterViewModel>) {
        _model = model
    }

    var body: some View {
        // TODO: - layout
        ScrollView {
            VStack {
                Divider()
                Button("filter") {
                    model.assetsRequest.filters = []
                    model.assetsRequest.filters.append(.hasBalance)
                }
                Button("Open chips") {
                    isPresentingChains.toggle()
                }

                HStack(spacing: Spacing.extraSmall) {
                    Text(model.chainFilterType.title)
                    Image(systemName: SystemImage.chevronDown)
                }
                .font(.body)
                .foregroundStyle(model.chainFilterType == CainsFilterType.primary ? .black : .white)
                .padding(.horizontal, Spacing.extraSmall + Spacing.small)
                .padding(.vertical, Spacing.extraSmall)
                .background(
                    Capsule()
                        .fill(model.chainFilterType == CainsFilterType.primary ? .white : Colors.blue)
                        .if(model.chainFilterType == CainsFilterType.primary) {
                            $0.stroke(Color.gray.opacity(0.33), lineWidth: 0.66)
                        }
                )

            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Filters")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Clear", action: onSelectClear)
                    .font(.body.bold())
            }

            ToolbarItem(placement: .primaryAction) {
                Button(action: onSelectClose) {
                    Image(systemName: "xmark")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 12, design: .rounded).bold())
                        .background {
                            Circle()
                                .foregroundStyle(.tertiary.opacity(0.12))
                                .frame(width: 30, height: 30)
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $isPresentingChains) {
            NavigationStack {
                ChipsSelectorScene(allChips: model.allChains, selectedChips: $model.assetsRequest.chains)
            }
            .presentationDetents([.medium])
        }
    }
}

// MARK: - Actions

extension AssetsFilterScene {
    private func onSelectClear() {
        // clean to default
    }

    private func onSelectClose() {
        dismiss()
    }
}

#Preview {
    NavigationStack {
        AssetsFilterScene(model: .constant(.init(wallet: .main, type: .buy)))
    }
}
