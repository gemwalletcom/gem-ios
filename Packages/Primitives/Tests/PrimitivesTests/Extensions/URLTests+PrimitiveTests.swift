// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing

@testable import Primitives

struct URLTests {

    @Test
    func testCleanHost() {
        #expect(URL(string: "https://www.example.com")?.cleanHost() == "example.com")
        #expect(URL(string: "https://www.example.com/about-us")?.cleanHost() == "example.com")
    }
}
