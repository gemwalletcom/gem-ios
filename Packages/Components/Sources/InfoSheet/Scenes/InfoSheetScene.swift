// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct InfoSheetScene: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isPresentedUrl: URL? = nil

    private let model: InfoSheetModelViewable

    public init(model: InfoSheetModelViewable) {
        self.model = model
    }

    public var body: some View {
        InfoSheetView(model: model)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .padding(.horizontal, .medium)
            .safeAreaInset(edge: .top, alignment: .trailing) {
                closeButton
                    .padding([.trailing, .top], .medium)
            }
            .if(model.button != nil) {
                $0.safeAreaInset(edge: .bottom) {
                    actionButton
                        .padding([.bottom], .medium)
                }
            }
            .presentationDetentsForCurrentDeviceSize()
            .presentationCornerRadius(.presentation.cornerRadius)
            .safariSheet(url: $isPresentedUrl)
    }

    private var closeButton: some View {
        Button(action: onClose) {
            Images.System.xmarkCircle
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: .large, weight: .bold))
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
    }

    private var actionButton: some View {
        StateButton(
            text: model.buttonTitle,
            action: onAction
        )
        .frame(maxWidth: .scene.button.maxWidth)
    }
}

// MARK: - Actions

extension InfoSheetScene {
    private func onClose() {
        dismiss()
    }

    private func onAction() {
        guard let button = model.button else { return }

        switch button {
        case .url(let url):
            isPresentedUrl = url
        case .action(_, let action):
            action()
        }
    }
}

// MARK: - Previews

struct InfoSheetPreviewModel: InfoSheetModelViewable {
    var title: String
    var description: String
    var buttonTitle: String
    var button: InfoSheetButton?
    var image: InfoSheetImage?

    init(
        title: String,
        description: String,
        buttonTitle: String,
        button: InfoSheetButton? = nil,
        image: InfoSheetImage? = nil
    ) {
        self.title = title
        self.description = description
        self.buttonTitle = buttonTitle
        self.button = button
        self.image = image
    }
}

#Preview {
    InfoSheetScene(
        model: InfoSheetPreviewModel(
            title: "Network Fees",
            description: "Network fees needed to pay the miners, quite a long message, double, triple, quadruple, quintuple, etc.",
            buttonTitle: "Continue",
            button: .action(title: "test", action: { print("Action") }),
            image: .image(Image(systemName: "bell"))
        )
    )
}
