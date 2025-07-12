// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Primitives

public struct ConnectionProposalScene: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var model: ConnectionProposalViewModel

    public init(model: ConnectionProposalViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        VStack {
            List {
                Section { } header: {
                    VStack(alignment: .center) {
                        AsyncImageView(url: model.imageUrl, size: 64)
                    }
                    .padding(.top, 8)
                }
                .cleanListRow()

                Section {
                    NavigationLink(value: Scenes.SelectWallet()) {
                        ListItemView(
                            title: model.walletTitle,
                            subtitle: model.walletName
                        )
                    }
                    ListItemView(title: model.appTitle, subtitle: model.appText)
                }
            }

            Button(model.buttonTitle, action: onAccept)
                .buttonStyle(.blue())
                .padding(.bottom, .scene.bottom)
                .frame(maxWidth: .scene.button.maxWidth)
        }
        .padding(.bottom, .scene.bottom)
        .background(Colors.grayBackground)
        .navigationTitle(model.title)
        .navigationDestination(for: Scenes.SelectWallet.self) { _ in
            SelectWalletScene(model: $model.walletSelectorModel)
        }
    }
}

// MARK: - Actions

extension ConnectionProposalScene {
    private func onAccept() {
        do {
            try model.accept()
            dismiss()
        } catch {
            NSLog("accept proposal error \(error)")
        }
    }
}
