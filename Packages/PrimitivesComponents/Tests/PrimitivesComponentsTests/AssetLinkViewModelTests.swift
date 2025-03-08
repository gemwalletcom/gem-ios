// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit

@testable import PrimitivesComponents

struct AssetLinkViewModelTests {
    @Test
    func testHost() {
        #expect(AssetLinkViewModel(.mock(type: .website)).host == "example.com")
        #expect(AssetLinkViewModel(.mock(type: .gitHub)).host == .none)
    }
}
