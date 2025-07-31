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
        #expect(TransferData.mock(type: .transfer(.mock())).type.shouldIgnoreValueCheck == false)

        #expect(TransferData.mock(type: .deposit(.mock())).type.shouldIgnoreValueCheck == false)
        #expect(TransferData.mock(type: .perpetual(.mock(), .open(.mock(direction: .long, assetIndex: 0, price: "100", size: "1")))).type.shouldIgnoreValueCheck == true)
        #expect(
            TransferData
                .mock(
                    type: .perpetual(.mock(), .close(.mock(direction: .long, assetIndex: 0, price: "100", size: "1")))
                ).type.shouldIgnoreValueCheck == true
        )
    }
    // MARK: - canChangeValue

    @Test
    func canChangeValue() {
        #expect(TransferData.mock(type: .transfer(.mock())).canChangeValue == true)
        #expect(TransferData.mock(type: .transfer(.mock()), canChangeValue: false).canChangeValue == false)

        #expect(TransferData.mock(type: .swap(.mock(), .mock(), .mock())).canChangeValue == true)

        #expect(TransferData.mock(type: .stake(.mock(), .stake(validator: .mock()))).canChangeValue == true)
        #expect(TransferData.mock(type: .stake(.mock(), .redelegate(delegation: .mock(), toValidator: .mock()))).canChangeValue == true)

        #expect(TransferData.mock(type: .stake(.mock(), .unstake(delegation: .mock(state: .inactive)))).canChangeValue == true)
        #expect(TransferData.mock(type: .stake(.mock(), .withdraw(delegation: .mock(state: .inactive)))).canChangeValue == true)
        #expect(TransferData.mock(type: .stake(.mock(), .rewards(validators: [.mock()]))).canChangeValue == true)

        #expect(TransferData.mock(type: .transferNft(.mock())).canChangeValue == true)
        #expect(TransferData.mock(type: .tokenApprove(.mock(), .mock())).canChangeValue == true)
        #expect(TransferData.mock(type: .account(.mock(), .activate)).canChangeValue == true)
        #expect(TransferData.mock(type: .generic(asset: .mock(), metadata: .mock(), extra: .mock(outputType: .encodedTransaction))).canChangeValue == true)

        #expect(TransferData.mock(type: .deposit(.mock())).canChangeValue == true)
        #expect(TransferData.mock(type: .deposit(.mock()), canChangeValue: false).canChangeValue == false)
        #expect(TransferData.mock(type: .perpetual(.mock(), .open(.mock(direction: .long, assetIndex: 0, price: "100", size: "1")))).canChangeValue == true)
        #expect(
            TransferData
                .mock(
                    type: .perpetual(.mock(), .close(.mock(direction: .long, assetIndex: 0, price: "100", size: "1"))),
                    canChangeValue: false
                ).canChangeValue == false
        )
    }
}
