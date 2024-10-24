// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

struct InfoSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL

    let model: InfoSheetViewModel

    init(type: InfoSheetType) {
        self.model = InfoSheetViewModel(type: type)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: .zero) {
                if model.url != nil {
                    Spacer()
                    InfoView(model: model)
                    Spacer()
                    StateButton(
                        text: model.buttonTitle,
                        styleState: .normal,
                        action: onLearnMore
                    )
                    .frame(maxWidth: Spacing.scene.button.maxWidth)
                } else {
                    InfoView(model: model)
                }
            }
            .padding(.horizontal, Spacing.medium)
            .if(model.url != nil) {
                $0.padding(.bottom, Spacing.scene.bottom)
            }
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
        guard let url = model.url else { return }
        openURL(url)
    }
}

// MARK: - Previews

#Preview {
    InfoSheet(type: .networkFees)
}
