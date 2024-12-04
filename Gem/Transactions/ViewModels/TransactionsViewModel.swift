// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Store
import GRDB
import GRDBQuery
import Keystore
import Localization

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

        self.filterModel = TransactionsFilterViewModel(
            chainsFilterModel: ChainsFilterViewModel(
                chains: wallet.chains(type: .all)
            ),
            transactionTypesFilter: TransacionTypesFilterViewModel(
                types: TransactionType.allCases
            )
        )
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
        self.filterModel = TransactionsFilterViewModel(
            chainsFilterModel: ChainsFilterViewModel(
                chains: wallet.chains(type: .all)
            ),
            transactionTypesFilter: TransacionTypesFilterViewModel(
                types: TransactionType.allCases
            )
        )
        self.request = TransactionsRequest(walletId: wallet.id, type: type)
    }

    func update(filterRequest: TransactionsRequestFilter) {
        request.filters.removeAll { existingFilter in
            switch (filterRequest, existingFilter) {
            case (.chains, .chains), (.types, .types):
                return true
            default:
                return false
            }
        }
        request.filters.append(filterRequest)
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
