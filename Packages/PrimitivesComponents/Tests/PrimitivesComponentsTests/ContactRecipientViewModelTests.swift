// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import PrimitivesComponents
import Primitives
import PrimitivesTestKit

struct ContactRecipientViewModelTests {

    @Test
    func listItemsCount() {
        let model = ContactRecipientViewModel(contactData: .mock(addresses: [.mock(), .mock(id: "address-2")]))

        #expect(model.listItems.count == 2)
    }

    @Test
    func listItemNameWithDescription() {
        let model = ContactRecipientViewModel(contactData: .mock(contact: .mock(name: "John"), addresses: [.mock(description: "Main Wallet")]))

        #expect(model.listItems.first?.value.name == "John - Main Wallet")
    }

    @Test
    func listItemNameWithoutDescription() {
        let model = ContactRecipientViewModel(contactData: .mock(contact: .mock(name: "John"), addresses: [.mock(chain: .ethereum, description: nil)]))

        #expect(model.listItems.first?.value.name == "John - Ethereum")
    }

    @Test
    func listItemAddress() {
        let model = ContactRecipientViewModel(contactData: .mock(addresses: [.mock(address: "0x1234567890")]))

        #expect(model.listItems.first?.value.address == "0x1234567890")
    }

    @Test
    func listItemMemo() {
        let model = ContactRecipientViewModel(contactData: .mock(addresses: [.mock(memo: "test-memo")]))

        #expect(model.listItems.first?.value.memo == "test-memo")
    }
}
