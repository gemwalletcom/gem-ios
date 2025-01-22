// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Store
import Localization
import Preferences
import TransactionsService
import ExplorerService

@Observable
@MainActor
public final class TransactionsViewModel {
    private let type: TransactionsRequestType
    private let preferences: SecurePreferences = .standard
    private let service: TransactionsService

    public var wallet: Wallet
    public var filterModel: TransactionsFilterViewModel
    public var request: TransactionsRequest

    public let explorerService: any ExplorerLinkFetchable = ExplorerService.standart

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
