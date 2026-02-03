// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Localization
import PrimitivesComponents
import Primitives

public struct SignMessageScene: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var model: SignMessageSceneViewModel

    public init(model: SignMessageSceneViewModel) {
        _model = State(wrappedValue: model)
    }

    public var body: some View {
        List {
            Section {
                ListItemImageView(
                    title: Localized.WalletConnect.app,
                    subtitle: model.appText,
                    assetImage: model.appAssetImage
                )
                .contextMenu(
                    .url(title: Localized.WalletConnect.website, onOpen: model.onViewWebsite)
                )
                ListItemView(title: Localized.Common.wallet, subtitle: model.walletText)
                ListItemView(title: Localized.Transfer.network, subtitle: model.networkText)
            }
            
            switch model.messageDisplayType {
            case .sections(let sections):
                ForEach(sections) { section in
                    Section {
                        ForEach(section.values) { item in
                            ListItemView(
                                title: item.title,
                                subtitle: item.value
                            )
                        }
                    } header: {
                        if let title = section.title {
                            Text(title)
                        }
                    }
                }
                NavigationCustomLink(with: ListItemView(title: Localized.SignMessage.viewFullMessage)) {
                    model.onViewFullMessage()
                }
            case .text(let string):
                Section(Localized.SignMessage.message) {
                    Text(string)
                }
            case .siwe(let message):
                let siweViewModel = SiweMessageViewModel(message: message)
                Section(Localized.Common.details) {
                    ForEach(Array(siweViewModel.detailItems.enumerated()), id: \.offset) { item in
                        ListItemView(title: item.element.title, subtitle: item.element.value)
                    }
                }
                NavigationCustomLink(with: ListItemView(title: Localized.SignMessage.viewFullMessage)) {
                    model.onViewFullMessage()
                }
            }
        }
        .safeAreaButton {
            StateButton(
                text: model.buttonTitle,
                action: sign
            )
        }
        .navigationTitle(Localized.SignMessage.title)
        .safariSheet(url: $model.isPresentingUrl)
        .sheet(isPresented: $model.isPresentingMessage) {
            NavigationStack {
                TextMessageScene(model: model.textMessageViewModel)
            }
        }
    }
    
    func sign() {
        Task {
            do {
                try await model.signMessage()
                dismiss()
            } catch {
                debugLog("sign message error \(error)")
            }
        }
    }
}
