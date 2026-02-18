// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
internal import GemstonePrimitives

public struct ContactRecipientViewModel {
    private let contactData: ContactData

    public init(contactData: ContactData) {
        self.contactData = contactData
    }

    public var listItems: [ListItemValue<RecipientAddress>] {
        contactData.addresses.map { address in
            ListItemValue(
                value: RecipientAddress(
                    name: name(for: address),
                    address: address.address,
                    memo: address.memo
                )
            )
        }
    }

    private func name(for address: ContactAddress) -> String {
        contactData.contact.name + " - " + (address.description ?? address.chain.asset.name)
    }
}
