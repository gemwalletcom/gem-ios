// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import Transfer
@testable import Primitives

struct TransferDataViewModelTests {

    @Test
    func testShouldShowMemo() {
        #expect(TransferDataViewModel.mock(type: .transfer(.mock(id: .mockEthereum()), isScanned: false)).shouldShowMemo == false)
        #expect(TransferDataViewModel.mock(type: .transfer(.mock(id: .mockSolana()), isScanned: false)).shouldShowMemo == true)
        #expect(TransferDataViewModel.mock(type: .transfer(.mock(id: .mockSolana()), isScanned: false)).shouldShowMemo == true)

        #expect(TransferDataViewModel.mock(type: .transferNft(.mock())).shouldShowMemo == false)
        #expect(TransferDataViewModel.mock(type: .transferNft(.mock())).shouldShowMemo == false)
        #expect(TransferDataViewModel.mock(type: .transferNft(.mock())).shouldShowMemo == false)
    }
}

private extension TransferDataViewModel {
    static func mock(
        type: TransferDataType = .transfer(.mock(), isScanned: false)
    ) -> TransferDataViewModel {
        return TransferDataViewModel(
            data: TransferData.mock(type: type)
        )
    }
}
