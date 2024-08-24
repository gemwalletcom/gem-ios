// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
@testable import GemstonePrimitives
import Primitives

final class ConfigTests: XCTestCase {

    func testSolanaProgramId() throws {

        XCTAssertEqual(SolanaConfig.tokenProgramId(owner: "TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb"), .token2022)
        XCTAssertEqual(SolanaConfig.tokenProgramId(owner: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"), .token)
        XCTAssertEqual(SolanaConfig.tokenProgramId(owner: "Token"), .none)
    }
}
