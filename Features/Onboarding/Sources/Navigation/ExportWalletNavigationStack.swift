// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization

enum ExportWalletDestination: Hashable {
    case words([String])
    case privateKey(String)
}

public struct ExportWalletNavigationStack: View {
    @Environment(\.dismiss) private var dismiss
    
    private let flow: ExportWalletFlow
    @State private var navigationPath: NavigationPath = NavigationPath()
    
    public init(flow: ExportWalletFlow) {
        self.flow = flow
    }

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
            .navigationDestination(for: ExportWalletDestination.self) {
                switch $0 {
                case .words(let words):
                    ShowSecretDataScene(model: ShowSecretPhraseViewModel(words: words))
                case .privateKey(let key):
                    ShowSecretDataScene(model: ShowPrivateKeyViewModel(text: key))
                }
            }
        }
    }
}

extension ExportWalletNavigationStack {
    private func onNext() {
        switch flow {
        case .words(let words):
            navigationPath.append(ExportWalletDestination.words(words))
        case .privateKey(let key):
            navigationPath.append(ExportWalletDestination.privateKey(key))
        }
    }
}
