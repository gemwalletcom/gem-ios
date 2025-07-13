// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
@testable import WalletConnectorService

struct MessageTrackerTests {
    
    @Test
    func shouldProcessUniqueMessages() async {
        let tracker = MessageTracker()
        
        #expect(await tracker.shouldProcess("message1") == true)
        #expect(await tracker.shouldProcess("message1") == false)
    }
}