// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Localization
import Style
import UIKit
import Formatters

public struct CopyTypeViewModel: Equatable, Hashable, Sendable {
    public let type: CopyType
    public let copyValue: String

    public init(type: CopyType, copyValue: String) {
        self.type = type
        self.copyValue = copyValue
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

    public var systemImage: String { SystemImage.copy }

    public var expirationTimeInternal: TimeInterval {
        switch type {
        case .secretPhrase, .privateKey: 60
        case .address: 500
        }
    }
    
    public func copy() {
        UIPasteboard.general.setItems([[UIPasteboard.typeAutomatic: copyValue]],
            options: [.localOnly: true, .expirationDate: Date().addingTimeInterval(expirationTimeInternal)]
        )
    }
}
