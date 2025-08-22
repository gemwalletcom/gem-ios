// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemSolanaTokenProgramId {
    public func map() -> SolanaTokenProgramId {
        switch self {
        case .token: .token
        case .token2022: .token2022
        }
    }
}