// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import Primitives

public extension WalletCore.SolanaTokenProgramId {
    var program: Primitives.SolanaTokenProgramId {
        switch self {
        case .token2022Program: .token2022
        case .tokenProgram, .UNRECOGNIZED: .token
        @unknown default:  .token
        }
    }
}

public extension Primitives.SolanaTokenProgramId {
    var program: WalletCore.SolanaTokenProgramId {
        switch self {
        case .token: .tokenProgram
        case .token2022: .token2022Program
        }
    }
}
