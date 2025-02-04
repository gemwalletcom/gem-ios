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

@Observable
@MainActor
public final class TransactionsViewModel {
    private let type: TransactionsRequestType
    private let preferences: SecurePreferences = .standard
    private let service: TransactionsService

    public var wallet: Wallet
    public var filterModel: TransactionsFilterViewModel
    public var request: TransactionsRequest

    public let explorerService: any ExplorerLinkFetchable = ExplorerService.standard
    public var isPresentingSelectAssetType: SelectAssetType?

    public init(
        wallet: Wallet,
        type: TransactionsRequestType,
        service: TransactionsService
    ) {
        self.wallet = wallet
        self.type = type
        self.service = service
        self.filterModel = TransactionsFilterViewModel(wallet: wallet)
        self.request = TransactionsRequest(walletId: wallet.id, type: type)
    }

    public var title: String { Localized.Activity.title }
    public var walletId: WalletId {
        WalletId(id: wallet.id)
    }

    public var emptyContentModel: EmptyContentTypeViewModel {
        if !filterModel.isAnyFilterSpecified {
            EmptyContentTypeViewModel(type: .activity(receive: onSelectReceive, buy: onSelectBuy))
        } else {
            EmptyContentTypeViewModel(type: .search(type: .transactions, action: onSelectCleanFilters))
        }
    }
}

// MARK: - Business Logic

extension TransactionsViewModel {
    public func refresh(for wallet: Wallet) {
        self.wallet = wallet
        self.filterModel = TransactionsFilterViewModel(wallet: wallet)
        self.request = TransactionsRequest(walletId: wallet.id, type: type)
    }

    public func onChangeFilter(_ _: TransactionsFilterViewModel, filter: TransactionsFilterViewModel) {
        request.filters = filter.requestFilters
    }

    public func fetch() async {
        do {
            guard let deviceId = try preferences.get(key: .deviceId) else {
                throw AnyError("deviceId is null")
            }
            try await service.updateAll(deviceId: deviceId, walletId: walletId)
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
