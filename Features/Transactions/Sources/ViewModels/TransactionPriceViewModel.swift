// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Components
import Formatters

public struct TransactionPriceViewModel: Sendable {
    private let metadata: TransactionMetadata?

    public init(metadata: TransactionMetadata?) {
        self.metadata = metadata
    }
}

extension TransactionPriceViewModel: ItemModelProvidable {
    public var itemModel: TransactionItemModel {
        guard case .perpetual(let perpetualMetadata) = metadata, perpetualMetadata.price > 0 else {
            return .empty
        }

        let formatter = CurrencyFormatter(type: .currency, currencyCode: Currency.usd.rawValue)
        let priceFormatted = formatter.string(perpetualMetadata.price)

        return .price(
            title: Localized.Asset.price,
            value: priceFormatted
        )
    }
}
