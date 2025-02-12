// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization

public struct ImportWalletNavigationStack: View {
    @Environment(\.dismiss) private var dismiss

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
        NavigationStack {
            ImportWalletTypeScene(model: model)
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
                            keystore: model.keystore,
                            onFinishImport: {
                                isPresentingWallets.toggle()
                            }
                        )
                    )
                }
        }
    }
}
