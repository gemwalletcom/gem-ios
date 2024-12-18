// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives

@testable import GemstonePrimitives

final class ConfigTests {
    @Test
    func testSolanaProgramId() {
        #expect(SolanaConfig.tokenProgramId(owner: "TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb") == .token2022)
        #expect(SolanaConfig.tokenProgramId(owner: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA") == .token)
        #expect(SolanaConfig.tokenProgramId(owner: "Token") == .none)
    }
}
