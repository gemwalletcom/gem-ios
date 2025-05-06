// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Localization
import PrimitivesComponents

public struct SignMessageScene: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isPresentingUrl: URL? = nil
    
    private let model: SignMessageSceneViewModel

    public init(model: SignMessageSceneViewModel) {
        self.model = model
    }

    public var body: some View {
        VStack {
            List {
                Section {
                    ListItemImageView(
                        title: Localized.WalletConnect.app,
                        subtitle: model.appName,
                        assetImage: model.appAssetImage
                    )
                    if let appUrl = model.appUrl {
                        ListItemView(title: Localized.WalletConnect.website, subtitle: model.connectionViewModel.host)
                            .contextMenu(
                                .url(title: Localized.WalletConnect.website, onOpen: {
                                    isPresentingUrl = appUrl
                                })
                            )
                    }
                    ListItemView(title: Localized.Common.wallet, subtitle: model.walletText)
                    ListItemView(title: Localized.Transfer.network, subtitle: model.networkText)
                }

                ForEach(model.messageSections) { section in
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
            }
            
            Button(role: .none) { sign() } label: {
                HStack {
                    //Image(systemName: model.buttonImage)
                    Text(model.buttonTitle)
                }
            }
            .buttonStyle(.blue())
            .padding(.bottom, .scene.bottom)
            .frame(maxWidth: .scene.button.maxWidth)
        }
        .padding(.bottom, .scene.bottom)
        .background(Colors.grayBackground)
        .navigationTitle(Localized.SignMessage.title)
        .safariSheet(url: $isPresentingUrl)
    }
    
    func sign() {
        do {
            try model.signMessage()
            dismiss()
        } catch {
            NSLog("sign message error \(error)")
        }
    }
}
