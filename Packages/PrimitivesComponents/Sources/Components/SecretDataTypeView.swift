// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct SecretDataTypeView: View {
    private let type: SecretPhraseDataType

    public init(type: SecretPhraseDataType) {
        self.type = type
    }

    public var body: some View {
        switch type {
        case .words(let rows):
            SecretPhraseGridView(rows: rows)
        case .privateKey(let key):
            Text(key)
                .multilineTextAlignment(.center)
                .padding(.horizontal, .medium)
                .frame(maxWidth: .scene.content.maxWidth)
        }
    }
}
