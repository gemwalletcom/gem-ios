// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives

struct SyncDiffTests {

    @Test 
    func calculate() async throws {
        let localChanges = SyncDiff.calculate(primary: .local, local: ["1", "2", "3"], remote: ["2", "4"])
        
        #expect(localChanges.toAdd == ["1", "3"])
        #expect(localChanges.toDelete == ["4"])
        
        let remoteChanges = SyncDiff.calculate(primary: .remote, local: ["1", "2", "3"], remote: ["2", "4"])
        
        #expect(remoteChanges.toAdd == ["4"])
        #expect(remoteChanges.toDelete == ["1", "3"])
    }
}
