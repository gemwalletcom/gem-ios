// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum ExportWalletType: Identifiable {
    public var id: String {
        switch self {
        case .words(let words): "words"
        case .privateKey(let key): "privateKey"
        }
    }

    case words([String])
    case privateKey(String)
}
