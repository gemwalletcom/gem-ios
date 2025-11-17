// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import ReownWalletKit
import enum Gemstone.WalletConnectionVerificationStatus

extension ReownWalletKit.VerifyContext.ValidationStatus {
    func map() -> WalletConnectionVerificationStatus {
        switch self {
        case .valid: .verified
        case .invalid: .invalid
        case .scam: .malicious
        case .unknown: .unknown
        }
    }
}
