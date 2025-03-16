// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Store
import Localization
import Preferences
import TransactionsService
import ExplorerService
import PrimitivesComponents
import ManageWalletService

@Observable
@MainActor
public final class TransactionsViewModel {
    public let explorerService: any ExplorerLinkFetchable = ExplorerService.standard

    private let manageWalletService: ManageWalletService
    private let transactionsService: TransactionsService

    private let type: TransactionsRequestType
    private let preferences: SecurePreferences = .standard

    public private(set) var wallet: Wallet

    public var transactions: [TransactionExtended] = []
    public var request: TransactionsRequest
    public var filterModel: TransactionsFilterViewModel
    public var isPresentingFilteringView: Bool = false

    public init(
        transactionsService: TransactionsService,
        manageWalletService: ManageWalletService,
        wallet: Wallet,
        type: TransactionsRequestType
    ) {
        self.manageWalletService = manageWalletService
        self.transactionsService = transactionsService

        self.type = type
        self.wallet = wallet
        self.filterModel = TransactionsFilterViewModel(wallet: wallet)
        self.request = TransactionsRequest(walletId: wallet.id, type: type)
    }

    public var title: String { Localized.Activity.title }
    public var currentWallet: Wallet? { manageWalletService.currentWallet }
    public var walletId: WalletId { wallet.walletId }

    public var emptyContentModel: EmptyContentTypeViewModel {
        if !filterModel.isAnyFilterSpecified {
            EmptyContentTypeViewModel(type: .activity(receive: onSelectReceive, buy: onSelectBuy))
        } else {
            EmptyContentTypeViewModel(type: .search(type: .activity, action: onSelectCleanFilters))
        }
    }
}

// MARK: - Business Logic

extension TransactionsViewModel {
    public func onChangeWallet(_ _: Wallet?, _ newWallet: Wallet?) {
        guard let newWallet else { return }
        wallet = newWallet
        filterModel = TransactionsFilterViewModel(wallet: wallet)
        request = TransactionsRequest(walletId: wallet.id, type: type)
    }

    public func onChangeFilter(_ _: TransactionsFilterViewModel, filter: TransactionsFilterViewModel) {
        request.filters = filter.requestFilters
    }

    public func onSelectFilterButton() {
        isPresentingFilteringView.toggle()
    }

    public func fetch() async {
        do {
            guard let deviceId = try preferences.get(key: .deviceId) else {
                throw AnyError("deviceId is null")
            }
            try await transactionsService.updateAll(deviceId: deviceId, walletId: walletId)
        } catch {
            NSLog("fetch getTransactions error \(error)")
        }
    }
}

// MARK: - Private

extension TransactionsViewModel {
    private func onSelectCleanFilters() {
        refresh(for: wallet)
    }

    private func onSelectReceive() {
        isPresentingSelectAssetType = .receive(.asset)
    }

    private func onSelectBuy() {
        isPresentingSelectAssetType = .buy
    }
}
