// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import Blockchain

struct JSONRPCIDGeneratorTests {

    @Test func nextId() async throws {
        let nextId = JSONRPCIDGenerator.shared.nextId()
        
        #expect(JSONRPCIDGenerator.shared.nextId() == nextId + 1)
        #expect(JSONRPCIDGenerator.shared.nextId() == nextId + 2)
    }
}
