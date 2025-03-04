// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import XCTest

@testable import Primitives

final class URLTests: XCTestCase {

    func testCleanHost() {
        XCTAssertEqual(URL(string: "https://www.example.com")?.cleanHost(), "example.com")
        XCTAssertEqual(URL(string: "https://www.example.co.uk/about-us")?.cleanHost(), "example.co.uk")
    }
}
