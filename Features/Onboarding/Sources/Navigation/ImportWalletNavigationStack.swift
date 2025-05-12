// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization

public struct ImportWalletNavigationStack: View {
    @Environment(\.dismiss) private var dismiss

    @State private var navigationPath: NavigationPath = NavigationPath()
    @Binding private var isPresentingWallets: Bool
    private let model: ImportWalletTypeViewModel

    public init(
        model: ImportWalletTypeViewModel,
        isPresentingWallets: Binding<Bool>
    ) {
        self.model = model
        _isPresentingWallets = isPresentingWallets
    }

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            AcceptTermsScene(model: AcceptTermsViewModel(
                onNext: {
                    navigationPath.append(Scenes.ImportWalletType())
                }
            ))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Localized.Common.cancel) {
                        dismiss()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ImportWalletType.self) { type in
                ImportWalletScene(
                    model: ImportWalletViewModel(
                        type: type,
                        walletService: model.walletService,
                        onFinishImport: {
                            isPresentingWallets.toggle()
                        }
                    )
                )
            }
            .navigationDestination(for: Scenes.ImportWalletType.self) { _ in
                ImportWalletTypeScene(model: model)
            }
        }
    }
}
