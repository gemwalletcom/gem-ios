// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
@testable import GemstonePrimitives
import Primitives

final class ConfigTests: XCTestCase {

    func testSolanaProgramId() throws {

        XCTAssertEqual(SolanaConfig.programId(owner: "TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb"), .token2022)
        XCTAssertEqual(SolanaConfig.programId(owner: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"), .token)
        XCTAssertEqual(SolanaConfig.programId(owner: "Token"), .none)
    }
}
