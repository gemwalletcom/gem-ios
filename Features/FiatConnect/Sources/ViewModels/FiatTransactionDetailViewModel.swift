// Copyright (c). Gem Wallet. All rights reserved.

import Components
import ExplorerService
import Formatters
import Foundation
import Localization
import Primitives
import PrimitivesComponents
import Store
import Style
import SwiftUI

@Observable
@MainActor
public final class FiatTransactionDetailViewModel {
    let asset: Asset
    private let explorerService: ExplorerService

    public let query: ObservableQuery<FiatTransactionRequest>
    var transaction: FiatTransaction { query.value }

    public init(
        transaction: FiatTransaction,
        walletId: WalletId,
        asset: Asset,
        explorerService: ExplorerService = .standard
    ) {
        self.asset = asset
        self.explorerService = explorerService
        self.query = ObservableQuery(FiatTransactionRequest(walletId: walletId, transaction: transaction), initialValue: transaction)
    }

    var title: String {
        switch transaction.transactionType {
        case .buy: Localized.Wallet.buy
        case .sell: Localized.Wallet.sell
        }
    }

    var headerModel: TransactionHeaderItemModel {
        let color: Color = switch transaction.status {
        case .failed: Colors.gray
        case .pending, .complete, .unknown: Colors.white
        }
        let amountText = AmountDisplay.currency(
            value: transaction.fiatAmount,
            currencyCode: transaction.fiatCurrency,
            textStyle: TextStyle(font: .body, color: color, fontWeight: .medium),
            showSign: false
        )
        let display = FiatAmountDisplay(
            amount: amountText,
            assetImage: AssetIdViewModel(assetId: asset.id).assetImage
        )
        return TransactionHeaderItemModel(
            headerType: .amount(.fiat(display)),
            showClearHeader: true
        )
    }
}

// MARK: - ListSectionProvideable

extension FiatTransactionDetailViewModel: ListSectionProvideable {
    public var sections: [ListSection<FiatTransactionDetailItem>] {
        var sections = [ListSection(type: .details, [.status, .provider])]
        if let _ = explorerLink {
            sections.append(ListSection(type: .explorer, [.explorerLink]))
        }
        return sections
    }

    public func itemModel(for item: FiatTransactionDetailItem) -> any ItemModelProvidable<FiatTransactionDetailItemModel> {
        switch item {
        case .status: statusModel
        case .provider: providerModel
        case .explorerLink: explorerModel
        }
    }
}

// MARK: - Private

extension FiatTransactionDetailViewModel {
    private var statusModel: FiatTransactionDetailItemModel {
        let model = FiatTransactionStatusViewModel(status: transaction.status)
        return .listItem(ListItemModel(
            title: Localized.Transaction.status,
            titleTagType: transaction.status == .pending ? .progressView() : .none,
            subtitle: model.title,
            subtitleStyle: TextStyle(font: .callout, color: model.color)
        ))
    }

    private var providerModel: FiatTransactionDetailItemModel {
        .listImageItem(
            title: Localized.Common.provider,
            subtitle: transaction.providerId.displayName,
            image: .image(transaction.providerId.image)
        )
    }

    private var explorerLink: BlockExplorerLink? {
        guard let hash = transaction.transactionHash else { return nil }
        return explorerService.transactionUrl(chain: asset.chain, hash: hash)
    }

    private var explorerModel: FiatTransactionDetailItemModel {
        guard let link = explorerLink else { return .empty }
        return .explorer(url: link.url, text: Localized.Transaction.viewOn(link.name))
    }
}
