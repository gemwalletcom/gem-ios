// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Localization

public struct CopyTypeViewModel {
    public let type: CopyType

    public init(type: CopyType) {
        self.type = type
    }

    public var message: String {
        switch type {
        case .secretPhrase: Localized.Common.copied(Localized.Common.secretPhrase)
        case .privateKey: Localized.Common.copied(Localized.Common.privateKey)
        case .address(let asset, let address):
            Localized.Common.copied(
                String(
                    format: "%@ (%@) ",
                    asset.name,
                    AddressFormatter(style: .short, address: address, chain: asset.chain).value()
                )
            )
        }
    }
}
