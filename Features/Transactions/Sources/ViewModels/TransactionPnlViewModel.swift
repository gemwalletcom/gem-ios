// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Components
import Formatters
import SwiftUI
import Style

public struct TransactionPnlViewModel: Sendable {
    private let metadata: TransactionMetadata?

    public init(metadata: TransactionMetadata?) {
        self.metadata = metadata
    }
}

extension TransactionPnlViewModel: ItemModelProvidable {
    public var itemModel: TransactionItemModel {
        guard case .perpetual(let perpetualMetadata) = metadata, perpetualMetadata.pnl != 0 else {
            return .empty
        }

        let formatter = CurrencyFormatter(type: .currency, currencyCode: Currency.usd.rawValue)
        let sign = perpetualMetadata.pnl >= 0 ? "+" : ""
        let pnlFormatted = formatter.string(perpetualMetadata.pnl)
        let color = perpetualMetadata.pnl >= 0 ? Colors.green : Colors.red

        return .pnl(
            title: Localized.Perpetual.pnl,
            value: "\(sign)\(pnlFormatted)",
            color: color
        )
    }
}
