// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

struct InfoSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL

    let model: InfoSheetViewModel

    init(viewModel: InfoSheetViewModel) {
        self.model = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                InfoView(model: model)
                Spacer()

                StateButton(
                    text: model.buttonTitle,
                    styleState: .normal,
                    action: onLearnMore
                )
                .frame(maxWidth: Spacing.scene.button.maxWidth)
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.bottom, Spacing.scene.bottom)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: onClose) {
                        Image(systemName: SystemImage.xmarkCircle)
                            .foregroundStyle(Colors.gray)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
}

// MARK: - Actions

extension InfoSheet {
    private func onClose() {
        dismiss()
    }

    private func onLearnMore() {
        openURL(model.url)
    }
}

// MARK: - Previews

#Preview {
    InfoSheet(viewModel: .init(item: .networkFees))
}
