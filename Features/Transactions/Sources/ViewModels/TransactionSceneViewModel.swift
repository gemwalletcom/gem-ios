// Copyright (c). Gem Wallet. All rights reserved.

import Components
import ExplorerService
import Foundation
import InfoSheet
import Preferences
import Primitives
import PrimitivesComponents
import Store
import SwiftUI

@Observable
@MainActor
public final class TransactionSceneViewModel {
    private let preferences: Preferences
    private let explorerService: ExplorerService

    var request: TransactionRequest
    var transactionExtended: TransactionExtended

    var isPresentingShareSheet = false
    var isPresentingInfoSheet: InfoSheetType? = .none

    public init(
        transaction: TransactionExtended,
        walletId: String,
        preferences: Preferences = Preferences.standard,
        explorerService: ExplorerService = ExplorerService.standard
    ) {
        self.preferences = preferences
        self.explorerService = explorerService
        self.transactionExtended = transaction
        self.request = TransactionRequest(walletId: walletId, transactionId: transaction.id)
    }

    var title: String { model.titleTextValue.text }
    var explorerURL: URL { explorerViewModel.itemModel.url }

    var sections: [ListSection<TransactionItem>] {
        [
            ListSection(type: .header, [.header]),
            ListSection(type: .swapAction, [.swapButton]),
            ListSection(type: .details, [.date, .status, .participant, .memo, .network, .provider, .fee]),
            ListSection(type: .explorer, [.explorerLink])
        ]
    }

    func itemModel(for item: TransactionItem) -> TransactionItemModel? {
        switch item {
        case .header: .header(headerViewModel.itemModel)
        case .swapButton: TransactionSwapButtonViewModel(transaction: transactionExtended).itemModel.map { .swapButton($0) }
        case .date: .date(TransactionDateViewModel(date: model.transaction.transaction.createdAt).itemModel)
        case .status: .status(TransactionStatusViewModel(state: model.transaction.transaction.state, onInfoAction: onStatusInfo).itemModel)
        case .participant: TransactionParticipantViewModel(transactionViewModel: model).itemModel.map { .participant($0) }
        case .memo: TransactionMemoViewModel(transaction: model.transaction.transaction).itemModel.map { .memo($0) }
        case .network: .network(TransactionNetworkViewModel(chain: model.transaction.asset.chain).itemModel)
        case .provider: TransactionProviderViewModel(transaction: model.transaction.transaction).itemModel.map { .provider($0) }
        case .fee: .fee(
            TransactionNetworkFeeViewModel(
                feeAmount: model.infoModel.feeDisplay?.amount.text ?? "",
                feeFiat: model.infoModel.feeDisplay?.fiat?.text,
                onInfoAction: onNetworkFeeInfo
            ).itemModel
        )
        case .explorerLink: .explorer(
            TransactionExplorerViewModel(
                transactionViewModel: model,
                explorerService: explorerService
            ).itemModel
        )
        }
    }
}

// MARK: - Actions

extension TransactionSceneViewModel {
    func onChangeTransaction(_ oldValue: TransactionExtended, _ newValue: TransactionExtended) {
        if oldValue != newValue {
            transactionExtended = newValue
        }
    }

    func onSelectTransactionHeader() {
        if let headerLink = headerViewModel.headerLink {
            UIApplication.shared.open(headerLink)
        }
    }

    func onSelectShare() {
        isPresentingShareSheet = true
    }

    func onNetworkFeeInfo() {
        let chain = model.transaction.transaction.assetId.chain
        isPresentingInfoSheet = .networkFee(chain)
    }

    func onStatusInfo() {
        let assetImage = model.assetImage
        isPresentingInfoSheet = .transactionState(
            imageURL: assetImage.imageURL,
            placeholder: assetImage.placeholder,
            state: model.transaction.transaction.state
        )
    }
}

// MARK: - Private

extension TransactionSceneViewModel {
    private var model: TransactionViewModel {
        TransactionViewModel(
            explorerService: ExplorerService.standard,
            transaction: transactionExtended,
            currency: preferences.currency
        )
    }
    
    private var headerViewModel: TransactionHeaderViewModel {
        TransactionHeaderViewModel(
            transaction: model.transaction,
            infoModel: model.infoModel
        )
    }

    private var explorerViewModel: TransactionExplorerViewModel {
        TransactionExplorerViewModel(
            transactionViewModel: model,
            explorerService: explorerService
        )
    }
}
