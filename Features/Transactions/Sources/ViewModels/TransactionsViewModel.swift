// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Store
import Localization
import TransactionsService
import ExplorerService
import PrimitivesComponents
import WalletService
import Preferences

@Observable
@MainActor
public final class TransactionsViewModel {
    public let explorerService: any ExplorerLinkFetchable = ExplorerService.standard
    public let transactionsService: TransactionsService
    public let preferences: Preferences

    private let walletService: WalletService
    private let type: TransactionsRequestType

    public private(set) var wallet: Wallet

    public var transactions: [TransactionExtended] = []
    public var filterModel: TransactionsFilterViewModel

    // TODO: - separate presenting sheet state logic to separate type
    public var isPresentingFilteringView: Bool = false
    public var isPresentingSelectAssetType: SelectAssetType?

    public init(
        transactionsService: TransactionsService,
        walletService: WalletService,
        wallet: Wallet,
        type: TransactionsRequestType,
        preferences: Preferences = .standard
    ) {
        self.walletService = walletService
        self.transactionsService = transactionsService

        self.type = type
        self.wallet = wallet
        self.filterModel = TransactionsFilterViewModel(wallet: wallet, type: type)
        self.preferences = preferences
    }

    public var title: String { Localized.Activity.title }
    public var currentWallet: Wallet? { walletService.currentWallet }
    public var walletId: WalletId { wallet.walletId }
    public var currency: String { preferences.currency }

    public var emptyContentModel: EmptyContentTypeViewModel {
        if !filterModel.isAnyFilterSpecified {
            EmptyContentTypeViewModel(type: .activity(receive: onSelectReceive, buy: onSelectBuy, isViewOnly: wallet.isViewOnly))
        } else {
            EmptyContentTypeViewModel(type: .search(type: .activity, action: onSelectCleanFilters))
        }
    }
}

// MARK: - Business Logic

extension TransactionsViewModel {
    public func onChangeWallet(_ oldWallet: Wallet?, _ newWallet: Wallet?) {
        if let newWallet, wallet != newWallet {
            refresh(for: newWallet)
        }
    }

    public func onSelectFilterButton() {
        isPresentingFilteringView.toggle()
    }

    public func fetch() async {
        do {
            try await transactionsService.updateAll(walletId: walletId)
        } catch {
            #debugLog("fetch getTransactions error \(error)")
        }
    }
}

// MARK: - Private

extension TransactionsViewModel {
    private func refresh(for wallet: Wallet) {
        self.wallet = wallet
        filterModel = TransactionsFilterViewModel(wallet: wallet, type: type)
    }

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
