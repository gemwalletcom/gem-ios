// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

enum CopyType {
    case secretPhrase
    case address(Asset, address: String)
}

struct CopyTypeViewModel {
    
    let type: CopyType
    
    var message: String {
        switch type {
        case .secretPhrase:
            return Localized.Common.copied(Localized.Common.secretPhrase)
        case .address(let asset, let address):
            return Localized.Common.copied(
                String(
                    format: "%@ (%@) ",
                    asset.name,
                    AddressFormatter(style: .short, address: address, chain: asset.chain).value()
                )
            )
        }
    }
}
