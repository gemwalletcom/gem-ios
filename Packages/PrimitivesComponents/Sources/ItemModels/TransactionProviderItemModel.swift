// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Style
import Localization
import Primitives
import class Gemstone.SwapProviderConfig

public struct TransactionProviderItemModel: ListItemViewable {
    private let providerId: String
    
    public init?(transaction: Transaction) {
        guard
            let metadata = transaction.metadata,
            case let .swap(metadata) = metadata,
            let providerId = metadata.provider
        else {
            return nil
        }
        self.providerId = providerId
    }
    
    private var providerName: String {
        SwapProviderConfig.fromString(id: providerId).inner().name
    }
    
    public var listItemModel: ListItemType {
        .basic(
            title: Localized.Common.provider,
            subtitle: providerName
        )
    }
}