// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public enum ExportWalletType: Identifiable {
    public var id: String {
        switch self {
        case .words: "words"
        case .privateKey: "privateKey"
        }
    }

    case words(SecretData)
    case privateKey(SecretData)
}
