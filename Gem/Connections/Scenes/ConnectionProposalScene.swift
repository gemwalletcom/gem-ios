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
                    NavigationLink(value: Scenes.WalletsSelector()) {
                        ListItemView(
                            title: Localized.Common.wallet,
                            subtitle: model.selectedWalletName
                        )
                    }
                    ListItemView(title: Localized.WalletConnect.app, subtitle: model.appText)
                    if let website = model.websiteText {
                        ListItemView(title: Localized.WalletConnect.website, subtitle: website)
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
        .navigationDestination(for: Scenes.WalletsSelector.self) { _ in
            WalletsSelectorScene(model: $model.walletSelectorModel)
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
