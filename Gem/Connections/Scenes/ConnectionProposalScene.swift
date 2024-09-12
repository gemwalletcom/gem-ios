// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Primitives

struct ConnectionProposalScene: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var model: ConnectionProposalViewModel

    init(model: ConnectionProposalViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        VStack {
            List {
                Section { } header: {
                    VStack(alignment: .center) {
                        AsyncImageView(url: model.imageUrl, size: 64)
                    }
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)
                .textCase(nil)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                
                Section {
                    NavigationLink(value: Scenes.SelectWallet()) {
                        ListItemView(
                            title: model.walletTitle,
                            subtitle: model.walletName
                        )
                    }
                    ListItemView(title: model.appTitle, subtitle: model.appText)
                    if let website = model.websiteText {
                        ListItemView(title: model.websiteTitle, subtitle: website)
                    }
                }
            }

            Button(model.buttonTitle, action: onAccept)
                .buttonStyle(.blue())
                .padding(.bottom, Spacing.scene.bottom)
                .frame(maxWidth: Spacing.scene.button.maxWidth)
        }
        .padding(.bottom, Spacing.scene.bottom)
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
