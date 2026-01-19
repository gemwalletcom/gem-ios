// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Foundation

@testable import PrimitivesComponents

struct ErrorExtensionTests {

    @Test
    func networkErrorDescription() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        #expect(error.networkOrNoDataDescription == error.localizedDescription)
    }

    @Test
    func nonNetworkErrorDescription() {
        let error = NSError(domain: "TestDomain", code: 500)
        #expect(error.networkOrNoDataDescription == "No data available")
    }
}
