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

    var dateItemModel: TransactionDateItemModel {
        TransactionDateItemModel(date: model.transaction.transaction.createdAt)
    }

    var participantViewModel: TransactionParticipantViewModel {
        TransactionParticipantViewModel(transactionViewModel: model)
    }
    
    var participantItemModel: TransactionParticipantItemModel? {
        participantViewModel.itemModel
    }

    var statusItemModel: TransactionStatusItemModel {
        TransactionStatusItemModel(
            state: model.transaction.transaction.state,
            onInfoAction: { [weak self] in self?.onStatusInfo() }
        )
    }

    var networkItemModel: TransactionNetworkItemModel {
        TransactionNetworkItemModel(chain: model.transaction.asset.chain)
    }
    
    var providerItemModel: TransactionProviderItemModel? {
        TransactionProviderItemModel(transaction: model.transaction.transaction)
    }

    var networkFeeItemModel: TransactionNetworkFeeItemModel {
        TransactionNetworkFeeItemModel(
            feeAmount: model.infoModel.feeDisplay?.amount.text ?? "",
            feeFiat: model.infoModel.feeDisplay?.fiat?.text,
            onInfoAction: { [weak self] in self?.onNetworkFeeInfo() }
        )
    }

    var memoItemModel: TransactionMemoItemModel? {
        let memoModel = TransactionMemoItemModel(memo: model.transaction.transaction.memo)
        return memoModel.showMemo ? memoModel : nil
    }
    
    var explorerItemModel: TransactionExplorerItemModel {
        TransactionExplorerItemModel(
            transaction: model.transaction,
            explorerService: explorerService
        )
    }
    
    var headerViewModel: TransactionHeaderViewModel {
        TransactionHeaderViewModel(
            transaction: model.transaction,
            infoModel: model.infoModel
        )
    }

    func onChangeTransaction(_ oldValue: TransactionExtended, _ newValue: TransactionExtended) {
        if oldValue != newValue {
            transactionExtended = newValue
        }
    }
}

// MARK: - Actions

extension TransactionSceneViewModel {
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
}
