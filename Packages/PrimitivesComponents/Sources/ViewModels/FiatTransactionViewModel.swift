// Copyright (c). Gem Wallet. All rights reserved.

import Components
import Formatters
import Foundation
import Localization
import Primitives
import Style
import SwiftUI

public struct FiatTransactionViewModel: Sendable {
    public let transaction: FiatTransaction

    public init(transaction: FiatTransaction) {
        self.transaction = transaction
    }

    public var listItemModel: ListItemModel {
        let statusModel = FiatTransactionStatusViewModel(status: transaction.status)
        return ListItemModel(
            title: title,
            titleStyle: TextStyle(font: Font.system(.body, weight: .medium), color: .primary),
            titleTag: titleTag(statusModel),
            titleTagStyle: titleTagStyle(statusModel),
            titleTagType: titleTagType,
            titleExtra: transaction.providerId.displayName,
            titleStyleExtra: .footnote,
            subtitle: subtitle,
            subtitleStyle: TextStyle(font: .body, color: subtitleColor, fontWeight: .medium),
            imageStyle: .asset(assetImage: .image(transaction.providerId.image))
        )
    }
}

// MARK: - Private

extension FiatTransactionViewModel {
    private var title: String {
        switch transaction.transactionType {
        case .buy: Localized.Wallet.buy
        case .sell: Localized.Wallet.sell
        }
    }

    private var titleTagType: TitleTagType {
        switch transaction.status {
        case .pending: .progressView()
        case .complete, .failed, .unknown: .none
        }
    }

    private func titleTag(_ model: FiatTransactionStatusViewModel) -> String? {
        switch transaction.status {
        case .complete: .none
        case .pending, .failed, .unknown: model.title
        }
    }

    private func titleTagStyle(_ model: FiatTransactionStatusViewModel) -> TextStyle {
        TextStyle(
            font: Font.system(.footnote, weight: .medium),
            color: model.color,
            background: model.background
        )
    }

    private var subtitle: String {
        CurrencyFormatter(currencyCode: transaction.fiatCurrency).string(transaction.fiatAmount)
    }

    private var subtitleColor: Color {
        switch transaction.status {
        case .failed: Colors.gray
        case .pending, .complete, .unknown: Colors.black
        }
    }
}
