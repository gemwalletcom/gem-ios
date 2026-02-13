// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

enum WalletSearchScope {
    static func chains(for wallet: Wallet) -> [Chain] {
        switch wallet.type {
        case .single, .view, .privateKey:
            [wallet.accounts.first?.chain].compactMap { $0 }
        case .multicoin:
            []
        }
    }
}
