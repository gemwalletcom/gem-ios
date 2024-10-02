// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives

struct ImportWalletNavigationStack: View {

    @Environment(\.keystore) private var keystore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ImportWalletTypeScene(model: ImportWalletTypeViewModel(keystore: keystore))
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
                        model: ImportWalletViewModel(type: type, keystore: keystore)
                    )
                }
        }
    }
}

// MARK: - Previews

#Preview {
    @Previewable @State var isPresenting: Bool = false
    return ImportWalletNavigationStack()
}
