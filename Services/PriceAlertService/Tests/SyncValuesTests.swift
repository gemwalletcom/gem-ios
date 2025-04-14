// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import PriceAlertService

struct SyncValuesTests {

    @Test func testChanges() async throws {
        let localChanges = SyncValues.changes(primary: .local, local: ["1", "2", "3"], remote: ["2", "4"])
        
        #expect(localChanges.missing == ["1", "3"])
        #expect(localChanges.delete == ["4"])
        
        let remoteChanges = SyncValues.changes(primary: .remote, local: ["1", "2", "3"], remote: ["2", "4"])
        
        #expect(remoteChanges.missing == ["4"])
        #expect(remoteChanges.delete == ["1", "3"])
    }
}
