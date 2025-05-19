// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum ExportWalletType: Identifiable {
    public var id: String {
        switch self {
        case .words: "words"
        case .privateKey: "privateKey"
        }
    }

    case words([String])
    case privateKey(String)
}
