// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct InfoSheetScene: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL

    private let model: InfoSheetModelViewable

    public init(model: InfoSheetModelViewable) {
        self.model = model
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.small) {
                if model.url != nil {
                    Spacer(minLength: 0)
                    InfoSheetView(model: model)
                        .padding(.horizontal, Spacing.small)
                    Spacer()
                    StateButton(
                        text: model.buttonTitle,
                        styleState: .normal,
                        action: onLearnMore
                    )
                    .frame(maxWidth: Spacing.scene.button.maxWidth)
                } else {
                    InfoSheetView(model: model)
                }
            }
            .padding(.horizontal, Spacing.medium)
            .if(model.url != nil) {
                $0.padding(.bottom, Spacing.scene.bottom)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: onClose) {
                        Images.System.xmarkCircle
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

extension InfoSheetScene {
    private func onClose() {
        dismiss()
    }

    private func onLearnMore() {
        guard let url = model.url else { return }
        openURL(url)
    }
}

// MARK: - Previews

struct InfoSheetPreviewModel: InfoSheetModelViewable {
    var title: String
    var description: String
    var buttonTitle: String
    var url: URL?
    var image: InfoSheetImage?
    
    init(
        title: String,
        description: String,
        buttonTitle: String,
        url: URL? = nil,
        image: InfoSheetImage? = nil
    ) {
        self.title = title
        self.description = description
        self.buttonTitle = buttonTitle
        self.url = url
        self.image = image
    }
}

#Preview {
    InfoSheetScene(
        model: InfoSheetPreviewModel(
            title: "Network Fees",
            description: "Network fees needed to pay the miners, quite a long message, double, triple, quadruple, quintuple, etc.",
            buttonTitle: "Continue",
            image: .image(Image(systemName: "bell"))
        )
    )
}
