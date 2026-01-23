// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization

enum ExportWalletDestination: Hashable {
    case words(SecretData)
    case privateKey(SecretData)
}

public struct ExportWalletNavigationStack: View {

    private let flow: ExportWalletType
    @State private var navigationPath: NavigationPath = NavigationPath()

    public init(flow: ExportWalletType) {
        self.flow = flow
    }

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                switch flow {
                case .words:
                    SecurityReminderScene(
                        model: SecurityReminderViewModelDefault(
                            title: Localized.Common.secretPhrase,
                            onNext: onNext
                        )
                    )
                case .privateKey(let secretData):
                    ShowSecretDataScene(model: ShowPrivateKeyViewModel(secretData: secretData))
                }
            }
            .toolbarDismissItem(type: .close, placement: .topBarLeading)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ExportWalletDestination.self) {
                switch $0 {
                case .words(let secretData):
                    ShowSecretDataScene(model: ShowSecretPhraseViewModel(secretData: secretData))
                case .privateKey(let secretData):
                    ShowSecretDataScene(model: ShowPrivateKeyViewModel(secretData: secretData))
                }
            }
        }
    }
}

extension ExportWalletNavigationStack {
    private func onNext() {
        switch flow {
        case .words(let secretData):
            navigationPath.append(ExportWalletDestination.words(secretData))
        case .privateKey(let secretData):
            navigationPath.append(ExportWalletDestination.privateKey(secretData))
        }
    }
}
