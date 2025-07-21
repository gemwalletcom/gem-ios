// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum SolanaMethods: String, CaseIterable, Codable, Sendable {
    case signMessage = "solana_signMessage"
    case signTransaction = "solana_signTransaction"
    case signAndSendTransaction = "solana_signAndSendTransaction"
    case signAllTransactions = "solana_signAllTransactions"
}
