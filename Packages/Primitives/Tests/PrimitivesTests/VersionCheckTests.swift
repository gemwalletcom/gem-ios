// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives

final class VersionCheckTests {
    @Test
    func testIsVersionHigher() {
        #expect(VersionCheck.isVersionHigher(new: "1.2.3", current: "1.0.0"))
        #expect(!VersionCheck.isVersionHigher(new: "1.0.0", current: "1.2.3"))
        #expect(!VersionCheck.isVersionHigher(new: "1.2.3", current: "1.2.3"))
        #expect(VersionCheck.isVersionHigher(new: "2.1.3.4", current: "2.1.3"))
        #expect(!VersionCheck.isVersionHigher(new: "1", current: "2"))
        #expect(VersionCheck.isVersionHigher(new: "0.1", current: "0.0.1"))
        #expect(!VersionCheck.isVersionHigher(new: "2.1.3", current: "2.1.3.4"))
    }
}
