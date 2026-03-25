// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Components
import Formatters
import Foundation
import Localization
import Primitives
import Style
import SwiftUI

public struct FiatTransactionViewModel: Sendable {
    private let info: FiatTransactionInfo
    private var transaction: FiatTransaction { info.transaction }
    private let formatter: ValueFormatter

    public init(info: FiatTransactionInfo, formatter: ValueFormatter = .short) {
        self.info = info
        self.formatter = formatter
    }

    public var listItemModel: ListItemModel {
        let statusModel = FiatTransactionStatusViewModel(status: transaction.status)
        return ListItemModel(
            title: typeTitle,
            titleStyle: TextStyle(font: Font.system(.body, weight: .medium), color: .primary),
            titleTag: titleTag(statusModel),
            titleTagStyle: titleTagStyle(statusModel),
            titleExtra: transaction.provider.displayName,
            titleStyleExtra: .footnote,
            subtitle: amount,
            subtitleStyle: TextStyle(font: .callout, color: subtitleColor, fontWeight: .semibold),
            subtitleExtra: fiatValueText,
            subtitleStyleExtra: TextStyle(font: .footnote, color: Colors.gray),
            imageStyle: .asset(assetImage: assetImage)
        )
    }
    
    public var detailsUrl: URL? {
        info.detailsUrl?.asURL
    }
}

// MARK: - Private

extension FiatTransactionViewModel {
    private var typeTitle: String {
        switch transaction.transactionType {
        case .buy: Localized.Wallet.buy
        case .sell: Localized.Wallet.sell
        }
    }

    private var assetImage: AssetImage {
        AssetIdViewModel(assetId: info.asset.id).assetImage
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

    private var amount: String {
        guard let value = BigInt(transaction.value) else { return "" }
        return formatter.string(value, decimals: info.asset.decimals.asInt, currency: info.asset.symbol)
    }

    private var fiatValueText: String {
        CurrencyFormatter(currencyCode: transaction.fiatCurrency).string(transaction.fiatAmount)
    }

    private var subtitleColor: Color {
        switch transaction.status {
        case .failed: Colors.gray
        case .pending, .complete, .unknown: Colors.black
        }
    }
}
