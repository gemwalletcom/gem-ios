// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
import Primitives

final class VersionCheckTests: XCTestCase {

    func testIsVersionHigher() {
        XCTAssertTrue(VersionCheck.isVersionHigher(new: "1.2.3", current: "1.0.0"))
        XCTAssertFalse(VersionCheck.isVersionHigher(new: "1.0.0", current: "1.2.3"))
        XCTAssertFalse(VersionCheck.isVersionHigher(new: "1.2.3", current: "1.2.3"))
        XCTAssertTrue(VersionCheck.isVersionHigher(new: "2.1.3.4", current: "2.1.3"))
        XCTAssertFalse(VersionCheck.isVersionHigher(new: "1", current: "2"))
        XCTAssertTrue(VersionCheck.isVersionHigher(new: "0.1", current: "0.0.1"))
        XCTAssertFalse(VersionCheck.isVersionHigher(new: "2.1.3", current: "2.1.3.4"))
    }
}
