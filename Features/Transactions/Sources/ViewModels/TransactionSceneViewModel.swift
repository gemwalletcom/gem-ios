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

    var dateViewModel: TransactionDateViewModel {
        TransactionDateViewModel(date: model.transaction.transaction.createdAt)
    }
    
    var dateItemModel: TransactionDateItemModel {
        dateViewModel.itemModel
    }

    var participantViewModel: TransactionParticipantViewModel {
        TransactionParticipantViewModel(transactionViewModel: model)
    }
    
    var participantItemModel: TransactionParticipantItemModel? {
        participantViewModel.itemModel
    }

    var statusViewModel: TransactionStatusViewModel {
        TransactionStatusViewModel(
            state: model.transaction.transaction.state,
            onInfoAction: onStatusInfo
        )
    }
    
    var statusItemModel: TransactionStatusItemModel {
        statusViewModel.itemModel
    }

    var networkViewModel: TransactionNetworkViewModel {
        TransactionNetworkViewModel(chain: model.transaction.asset.chain)
    }
    
    var networkItemModel: TransactionNetworkItemModel {
        networkViewModel.itemModel
    }
    
    var providerViewModel: TransactionProviderViewModel {
        TransactionProviderViewModel(transaction: model.transaction.transaction)
    }
    
    var providerItemModel: TransactionProviderItemModel? {
        providerViewModel.itemModel
    }

    var networkFeeViewModel: TransactionNetworkFeeViewModel {
        TransactionNetworkFeeViewModel(
            feeAmount: model.infoModel.feeDisplay?.amount.text ?? "",
            feeFiat: model.infoModel.feeDisplay?.fiat?.text,
            onInfoAction: onNetworkFeeInfo
        )
    }
    
    var networkFeeItemModel: TransactionNetworkFeeItemModel {
        networkFeeViewModel.itemModel
    }

    var memoViewModel: TransactionMemoViewModel {
        TransactionMemoViewModel(transaction: model.transaction.transaction)
    }
    
    var memoItemModel: TransactionMemoItemModel? {
        memoViewModel.itemModel
    }
    
    var explorerViewModel: TransactionExplorerViewModel {
        TransactionExplorerViewModel(
            transactionViewModel: model,
            explorerService: explorerService
        )
    }
    
    var explorerItemModel: TransactionExplorerItemModel {
        explorerViewModel.itemModel
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
