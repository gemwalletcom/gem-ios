// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Formatters

struct ContactRecipientSectionViewModel {
    private let contacts: [ContactData]

    init(contacts: [ContactData]) {
        self.contacts = contacts
    }

    var listItems: [ListItemValue<RecipientAddress>] {
        contacts.flatMap { contactData in
            contactData.addresses.map { address in
                ListItemValue(
                    title: contactData.contact.name,
                    subtitle: AddressFormatter(address: address.address, chain: address.chain).value(),
                    value: RecipientAddress(name: contactData.contact.name, address: address.address, memo: address.memo)
                )
            }
        }
    }
}
