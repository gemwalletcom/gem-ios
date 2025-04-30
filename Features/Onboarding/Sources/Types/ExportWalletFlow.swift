// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum ExportWalletFlow: Identifiable {
    public var id: String {
        switch self {
        case .words(let words): words.joined()
        case .privateKey(let key): key
        }
    }

    case words([String])
    case privateKey(String)
}
