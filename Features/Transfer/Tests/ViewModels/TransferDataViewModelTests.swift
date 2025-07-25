// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import Transfer
@testable import Primitives
import PrimitivesTestKit

struct TransferDataViewModelTests {

    @Test
    func testShouldShowMemo() {
        #expect(TransferDataViewModel.mock(type: .transfer(.mock(id: .mockEthereum()), mode: .flexible)).shouldShowMemo == false)
        #expect(TransferDataViewModel.mock(type: .transfer(.mock(id: .mockSolana()), mode: .flexible)).shouldShowMemo == true)
        #expect(TransferDataViewModel.mock(type: .transfer(.mock(id: .mockSolana()), mode: .flexible)).shouldShowMemo == true)

        #expect(TransferDataViewModel.mock(type: .transferNft(.mock())).shouldShowMemo == false)
        #expect(TransferDataViewModel.mock(type: .transferNft(.mock())).shouldShowMemo == false)
        #expect(TransferDataViewModel.mock(type: .transferNft(.mock())).shouldShowMemo == false)
    }
}

private extension TransferDataViewModel {
    static func mock(
        type: TransferDataType = .transfer(.mock(), mode: .flexible)
    ) -> TransferDataViewModel {
        return TransferDataViewModel(
            data: TransferData.mock(type: type)
        )
    }
}
