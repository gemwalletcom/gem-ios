// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Primitives

public struct InfoSheetScene: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isPresentedUrl: URL? = nil

    private let model: InfoSheetModel

    public init(type: InfoSheetType) {
        self.model = InfoSheetModelFactory.create(from: type)
    }

    public var body: some View {
        NavigationStack {
            InfoSheetView(model: model)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .padding(.horizontal, .medium)
                .toolbar(content: {
                    Button("", systemImage: SystemImage.xmark) {
                        dismiss()
                    }
                    .liquidGlass { view in
                        view
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.circle)
                            .padding(.top, .medium)
                    }
                })
                .if(model.shouldShowButton) {
                    $0.safeAreaInset(edge: .bottom) {
                        actionButton
                            .padding([.bottom], .medium)
                    }
                }
                .presentationDetentsForCurrentDeviceSize()
                .safariSheet(url: $isPresentedUrl)
        }
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
