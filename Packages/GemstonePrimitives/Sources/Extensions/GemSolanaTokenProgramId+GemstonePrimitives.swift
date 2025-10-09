// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.SolanaTokenProgramId {
    public func map() -> Primitives.SolanaTokenProgramId {
        switch self {
        case .token: .token
        case .token2022: .token2022
        }
    }
}

extension Primitives.SolanaTokenProgramId {
    public func map() -> Gemstone.SolanaTokenProgramId {
        switch self {
        case .token: .token
        case .token2022: .token2022
        }
    }
}
