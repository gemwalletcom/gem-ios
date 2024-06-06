// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
@testable import Store
import StoreTestKit

final class StoreTests: XCTestCase {
    func testExample() throws {
        XCTAssertNotNil(PreferencesStore.mock())
    }
}
