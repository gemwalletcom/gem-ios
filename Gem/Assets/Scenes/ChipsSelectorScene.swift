// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct ChipsSelectorScene: View {
    @Environment(\.dismiss) var dismiss

    var allChips: [String]
    @Binding var selectedChips: [String]

    var body: some View {
        ScrollView {
            VStack {
                ChipsView(data: allChips, spacing: 8) {
                    Text($0)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                        .onTapGesture {
                            
                        }
                }
                Spacer()
            }
            .padding()
            .background (
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red)
                )
            .padding()
        }
        .frame(maxWidth: .infinity)
        .navigationTitle("Chains")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel", action: onSelectClose)
                    .font(.body.bold())
                    .buttonStyle(.plain)
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Apply", action: onSelectClose)
                    .font(.body.bold())
                    .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Actions

extension ChipsSelectorScene {
    private func onSelectClose() {
        dismiss()
    }

    private func onSelectApply() {
        // TODO: -
        dismiss()
    }
}

#Preview {
    ChipsSelectorScene(allChips: [], selectedChips: .constant([]))
}
