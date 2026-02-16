// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import PrimitivesComponents
import Style
import Formatters

struct ContactViewModel {
    let contact: Contact

    var listItemModel: ListItemModel {
        ListItemModel(
            title: contact.name,
            titleStyle: .body.weight(.semibold),
            titleExtra: formattedAddress,
            titleStyleExtra: .calloutSecondary,
            imageStyle: .asset(assetImage: assetImage)
        )
    }

    private var assetImage: AssetImage {
        AssetImage.image(ChainImage(chain: contact.chain).placeholder)
    }

    private var formattedAddress: String {
        AddressFormatter(
            style: .short,
            address: contact.address,
            chain: contact.chain
        ).value()
    }
}
