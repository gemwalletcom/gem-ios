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
        #expect(TransferData.mock(type: .transfer(.mock(), mode: .flexible)).type.shouldIgnoreValueCheck == false)
        #expect(TransferData.mock(type: .transfer(.mock(), mode: .fixed)).type.shouldIgnoreValueCheck == true)
    }
    // MARK: - canChangeValue

    @Test
    func canChangeValue() {
        #expect(TransferData.mock(type: .transfer(.mock(), mode: .flexible)).type.canChangeValue == true)
        #expect(TransferData.mock(type: .transfer(.mock(), mode: .fixed)).type.canChangeValue == false)

        #expect(TransferData.mock(type: .swap(.mock(), .mock(), .mock())).type.canChangeValue == true)

        #expect(TransferData.mock(type: .stake(.mock(), .stake(validator: .mock()))).type.canChangeValue == true)
        #expect(TransferData.mock(type: .stake(.mock(), .redelegate(delegation: .mock(), toValidator: .mock()))).type.canChangeValue == true)

        #expect(TransferData.mock(type: .stake(.mock(), .unstake(delegation: .mock(state: .inactive)))).type.canChangeValue == false)
        #expect(TransferData.mock(type: .stake(.mock(), .withdraw(delegation: .mock(state: .inactive)))).type.canChangeValue == false)
        #expect(TransferData.mock(type: .stake(.mock(), .rewards(validators: [.mock()]))).type.canChangeValue == false)

        #expect(TransferData.mock(type: .transferNft(.mock())).type.canChangeValue == false)
        #expect(TransferData.mock(type: .tokenApprove(.mock(), .mock())).type.canChangeValue == false)
        #expect(TransferData.mock(type: .account(.mock(), .activate)).type.canChangeValue == false)
        #expect(TransferData.mock(type: .generic(asset: .mock(), metadata: .mock(), extra: .mock(outputType: .encodedTransaction))).type.canChangeValue == false)
    }
}
