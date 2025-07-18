// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import Transfer
@testable import Primitives
import AddressNameServiceTestKit
import StoreTestKit
import AddressNameService
import Store

struct TransferDataViewModelTests {

    @Test
    func testShouldShowMemo() {
        #expect(TransferDataViewModel.mock(data: .mock(type: .transfer(.mock(id: .mockEthereum())))).shouldShowMemo == false)
        #expect(TransferDataViewModel.mock(data: .mock(type: .transfer(.mock(id: .mockSolana())))).shouldShowMemo == true)
        #expect(TransferDataViewModel.mock(data: .mock(type: .transfer(.mock(id: .mockSolana())))).shouldShowMemo == true)
        
        #expect(TransferDataViewModel.mock(data: .mock(type: .transferNft(.mock()))).shouldShowMemo == false)
        #expect(TransferDataViewModel.mock(data: .mock(type: .transferNft(.mock()))).shouldShowMemo == false)
        #expect(TransferDataViewModel.mock(data: .mock(type: .transferNft(.mock()))).shouldShowMemo == false)
    }
    
    @Test
    func recipientNameUsesStoredAddressName() throws {
        let addressName = AddressName.mock(chain: .ethereum)
        let db = DB.mockAssets()
        
        let addressStore = AddressStore.mock(db: db)
        try addressStore.addAddressNames([addressName])
        let addressNameService = AddressNameService.mock(addressStore: addressStore)
        
        let viewModel = TransferDataViewModel.mock(
            data: .mock(
                type: .transfer(.mockEthereum()),
                recipientData: .mock(recipient: .mock(address: addressName.address))
            ),
            addressNameService: addressNameService
        )
        
        #expect(viewModel.recepientAccount.name == addressName.name)
    }
}

private extension TransferDataViewModel {
    static func mock(
        data: TransferData = .mock(),
        addressNameService: AddressNameService = .mock()
    ) -> TransferDataViewModel {
        TransferDataViewModel(
            data: data,
            addressNameService: addressNameService
        )
    }
}
