// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Store
import GRDB
import GRDBQuery
import Keystore
import Localization
import Preferences

@Observable
final class TransactionsViewModel {
    private let type: TransactionsRequestType
    private let preferences: SecurePreferences = .standard
    private let service: TransactionsService

    var wallet: Wallet
    var filterModel: TransactionsFilterViewModel
    var request: TransactionsRequest

    init(
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

    var title: String { Localized.Activity.title }
    var walletId: WalletId {
        WalletId(id: wallet.id)
    }
}

// MARK: - Business Logic

extension TransactionsViewModel {
    func refresh(for wallet: Wallet) {
        self.wallet = wallet
        self.filterModel = TransactionsFilterViewModel(wallet: wallet)
        self.request = TransactionsRequest(walletId: wallet.id, type: type)
    }

    func onChangeFilter(_ _: TransactionsFilterViewModel, filter: TransactionsFilterViewModel) {
        request.filters = filter.requestFilters
    }

    func fetch() async {
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
