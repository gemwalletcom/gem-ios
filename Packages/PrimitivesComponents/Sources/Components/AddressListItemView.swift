// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style
import Localization

// TODO: - remove explorerService dependency get address link in init
public struct AddressListItemView: View {
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
        .contextMenu(
            [
                .copy(value: model.account.address),
                .url(title: model.addressExplorerText, url: model.addressExplorerUrl)
            ]
        )
    }
}
