// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Store

struct AssetsFilterScene: View {
    @Environment(\.dismiss) var dismiss
    @Binding var model: AssetsFilterViewModel

    init(model: Binding<AssetsFilterViewModel>) {
        _model = model
    }

    var body: some View {
        // TODO: - layout
        ScrollView {
            VStack {
                Text("some Filters")
                Divider()
                Button("filter") {
                    model.assetsRequest.filters = []
                    model.assetsRequest.filters.append(.hasBalance)
                }
            }
        }
        .frame(maxWidth: .infinity)
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
    AssetsFilterScene(model: .constant(.init(wallet: .main, type: .buy)))
}
