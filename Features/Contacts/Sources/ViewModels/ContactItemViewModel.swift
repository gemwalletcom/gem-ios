// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components

public struct ContactItemViewModel: Identifiable {
    public let contactData: ContactData

    public init(contactData: ContactData) {
        self.contactData = contactData
    }

    public var id: String { contactData.id }

    private var contact: Contact { contactData.contact }

    var listItemModel: ListItemModel {
        ListItemModel(
            title: contact.name,
            titleExtra: contact.description,
            imageStyle: .asset(assetImage: AssetImage(type: String(contact.name.prefix(2))))
        )
    }
}
