// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Localization
import Components
import class Gemstone.SwapProviderConfig

public struct TransactionProviderViewModel: Sendable {
    private let transaction: Transaction

    public init(transaction: Transaction) {
        self.transaction = transaction
    }
}

// MARK: - ItemModelProvidable

extension TransactionProviderViewModel: ItemModelProvidable {
    public var itemModel: TransactionItemModel {
        guard
            let metadata = transaction.metadata, case let .swap(metadata) = metadata,
            let providerId = metadata.provider
        else {
            return .empty
        }
        
        return .listItem(
            .text(
                title: Localized.Common.provider,
                subtitle: SwapProviderConfig.fromString(id: providerId).inner().name
            )
        )
    }
}
