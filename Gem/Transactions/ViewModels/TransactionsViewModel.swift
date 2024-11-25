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
class TransactionsViewModel {
    private let type: TransactionsRequestType
    private let preferences: SecurePreferences = .standard
    private let service: TransactionsService

    let walletId: WalletId
    let wallet: Wallet
    var filterModel: TransactionsFilterViewModel
    var request: TransactionsRequest

    init(
        walletId: WalletId,
        wallet: Wallet,
        type: TransactionsRequestType,
        service: TransactionsService
    ) {
        self.walletId = walletId
        self.wallet = wallet
        self.type = type
        self.service = service

        self.filterModel = TransactionsFilterViewModel(
            model: ChainsFilterViewModel(
                allChains: wallet.chains(type: .all),
                selectedChains: []
            )
        )
        self.request = TransactionsRequest(walletId: walletId.id, type: type)
    }

    var title: String { Localized.Activity.title }

    var showFilter: Bool {
        request.filters.isEmpty
    }
}

// MARK: - Business Logic

extension TransactionsViewModel {
    func updateFilterRequest(chains: [Chain]) {
        request.filters.removeAll(where: { $0.associatedChains.count > 0 })
        let rawValues = chains.map { $0.rawValue }
        request.filters.append(.chains(rawValues))
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
