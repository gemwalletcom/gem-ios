// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension SolanaTokenProgramId {
    
    static func from(string: String) throws -> SolanaTokenProgramId {
        guard let tokenProgram = SolanaTokenProgramId(rawValue: string) else {
            throw AnyError("Unknown Solana token program: \(string)")
        }
        return tokenProgram
    }
}