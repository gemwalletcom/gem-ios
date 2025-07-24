// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit

struct TransferDataTypeTests {
    
    @Test
    func shouldIgnoreValueCheck() {
        #expect(TransferData.mock(type: .transferNft(.mock())).type.shouldIgnoreValueCheck == true)
        #expect(TransferData.mock(type: .stake(.mock(), .stake(validator: .mock()))).type.shouldIgnoreValueCheck == true)
        #expect(TransferData.mock(type: .account(.mock(), .activate)).type.shouldIgnoreValueCheck == true)
        #expect(TransferData.mock(type: .transfer(.mock(), isScanned: false)).type.shouldIgnoreValueCheck == false)
    }
}
