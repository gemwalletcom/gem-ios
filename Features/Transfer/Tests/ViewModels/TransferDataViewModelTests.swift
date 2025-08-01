// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import Transfer
@testable import Primitives
import PrimitivesTestKit

struct TransferDataViewModelTests {

    @Test
    func testShouldShowMemo() {
        #expect(TransferDataViewModel.mock(type: .transfer(.mock(id: .mockEthereum()))).shouldShowMemo == false)
        #expect(TransferDataViewModel.mock(type: .transfer(.mock(id: .mockSolana()))).shouldShowMemo == true)
        #expect(TransferDataViewModel.mock(type: .transfer(.mock(id: .mockSolana()))).shouldShowMemo == true)

        #expect(TransferDataViewModel.mock(type: .deposit(.mock(id: .mockEthereum()))).shouldShowMemo == false)
        #expect(TransferDataViewModel.mock(type: .deposit(.mock(id: .mockSolana()))).shouldShowMemo == true)
        
        #expect(TransferDataViewModel.mock(type: .transferNft(.mock())).shouldShowMemo == false)
    }
    
    func depositTitle() {
        #expect(TransferDataViewModel.mock(type: .deposit(.mock())).title == "Deposit")
    }
}

private extension TransferDataViewModel {
    static func mock(
        type: TransferDataType = .transfer(.mock())
    ) -> TransferDataViewModel {
        return TransferDataViewModel(
            data: TransferData.mock(type: type)
        )
    }
}
