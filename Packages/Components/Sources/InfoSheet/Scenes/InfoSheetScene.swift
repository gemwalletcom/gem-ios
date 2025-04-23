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
            .if(model.url != nil) {
                $0.safeAreaInset(edge: .bottom) {
                    learnMoreButton
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

    private var learnMoreButton: some View {
        StateButton(
            text: model.buttonTitle,
            styleState: .normal,
            action: onLearnMore
        )
        .frame(maxWidth: .scene.button.maxWidth)
    }
}

// MARK: - Actions

extension InfoSheetScene {
    private func onClose() {
        dismiss()
    }

    private func onLearnMore() {
        guard let url = model.url else { return }
        isPresentedUrl = url
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
