// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct SecretDataTypeView: View {
    public let type: SecretPhraseDataType

    public init(type: SecretPhraseDataType) {
        self.type = type
    }

    public var body: some View {
        switch type {
        case .words(let rows):
            SecretPhraseGridView(rows: rows)
                .padding(.top, Spacing.scene.top)
        case .privateKey(let key):
            Text(key)
                .padding(.top, Spacing.scene.top)
        }
    }
}
