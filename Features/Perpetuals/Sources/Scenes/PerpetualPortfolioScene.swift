// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style
import Localization

public struct PerpetualPortfolioScene: View {
    @Environment(\.dismiss) private var dismiss

    public init() {
    }

    public var body: some View {
        NavigationStack {
            List {
                // TODO: Add portfolio content
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(Localized.Common.done) {
                        dismiss()
                    }
                }
            }
        }
    }
}
