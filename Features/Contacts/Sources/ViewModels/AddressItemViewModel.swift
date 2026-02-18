// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import PrimitivesComponents
import Formatters

struct AddressItemViewModel {
    let address: ContactAddress

    var listItemModel: ListItemModel {
        ListItemModel(
            title: title,
            titleExtra: formattedAddress,
            imageStyle: .asset(assetImage: assetImage)
        )
    }

    private var title: String {
        if let description = address.description, !description.isEmpty {
            return description
        }
        return address.chain.asset.name
    }

    private var assetImage: AssetImage {
        AssetIdViewModel(assetId: address.chain.assetId).assetImage
    }

    private var formattedAddress: String {
        AddressFormatter(
            style: .short,
            address: address.address,
            chain: address.chain
        ).value()
    }
}
