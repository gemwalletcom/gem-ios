// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization

public struct ExportWalletNavigationStack: View {
    @Environment(\.dismiss) private var dismiss
    
    private let flow: ExportWalletFlow
    
    public init(flow: ExportWalletFlow) {
        self.flow = flow
    }

    @State private var navigationPath: NavigationPath = NavigationPath()

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            SecurityReminderScene(
                model: SecurityReminderViewModelDefault(
                    title: Localized.Common.secretPhrase,
                    onNext: onNext
                )
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Localized.Common.cancel) {
                        dismiss()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Scenes.ShowWords.self) {
                ShowSecretDataScene(model: ShowSecretPhraseViewModel(words: $0.words))
            }
            .navigationDestination(for: Scenes.ShowPrivateKey.self) {
                ShowSecretDataScene(model: ShowPrivateKeyViewModel(text: $0.privateKey))
            }
        }
    }
}

extension ExportWalletNavigationStack {
    private func onNext() {
        switch flow {
        case .words(let words):
            navigationPath.append(Scenes.ShowWords(words: words))
        case .privateKey(let key):
            navigationPath.append(Scenes.ShowPrivateKey(privateKey: key))
        }
    }
}
