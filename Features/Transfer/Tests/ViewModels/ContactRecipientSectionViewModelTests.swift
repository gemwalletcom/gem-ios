// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit
@testable import Transfer

struct ContactRecipientSectionViewModelTests {

    @Test
    func listItemsEmpty() {
        #expect(ContactRecipientSectionViewModel(contacts: [], chain: .bitcoin).listItems.isEmpty)
    }

    @Test
    func listItems() {
        let address = ContactAddress.mock(address: "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh", chain: .bitcoin, memo: "test memo")
        let contact = ContactData.mock(contact: .mock(name: "Alice"), addresses: [address])
        let model = ContactRecipientSectionViewModel(contacts: [contact], chain: .bitcoin)

        #expect(model.listItems.first?.title == "Alice")
        #expect(model.listItems.first?.subtitle == "bc1qxy...x0wlh")
        #expect(model.listItems.first?.value.name == "Alice")
        #expect(model.listItems.first?.value.address == "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh")
        #expect(model.listItems.first?.value.memo == "test memo")
    }

    @Test
    func listItemsMultipleAddresses() {
        let addresses = [
            ContactAddress.mock(id: "1", address: "bc1q111", chain: .bitcoin),
            ContactAddress.mock(id: "2", address: "bc1q222", chain: .bitcoin)
        ]
        let contact = ContactData.mock(addresses: addresses)

        #expect(ContactRecipientSectionViewModel(contacts: [contact], chain: .bitcoin).listItems.count == 2)
    }
}
