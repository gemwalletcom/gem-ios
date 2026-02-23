// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style
import Localization

public struct AddressListItemView: View {
    @State private var isPresentingUrl: URL? = nil
    private let model: AddressListItemViewModel

    public init(
        model: AddressListItemViewModel
    ) {
        self.model = model
    }

    public var body: some View {
        ListItemImageView(
            title: model.title,
            subtitle: model.subtitle,
            assetImage: model.assetImage
        )
        .contextMenu(contextMenuItems)
        .safariSheet(url: $isPresentingUrl)
    }

    private var contextMenuItems: [ContextMenuItemType] {
        let items: [ContextMenuItemType] = [
            .copy(value: model.account.address),
            .url(title: model.addressExplorerText, onOpen: { isPresentingUrl = model.addressExplorerUrl })
        ]
        if let onAddContact = model.onAddContact {
            return items + [.custom(title: Localized.Contacts.addToContacts, systemImage: SystemImage.personBadgePlus, action: onAddContact)]
        }
        return items
    }
}
