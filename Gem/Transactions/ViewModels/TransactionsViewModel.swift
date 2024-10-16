// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Store
import GRDB
import GRDBQuery
import Keystore
import Localization

struct TransactionsViewModel {
    let walletId: WalletId
    let wallet: Wallet //TODO: Remove later

    private let type: TransactionsRequestType
    private let preferences: SecurePreferences = .standard
    private let service: TransactionsService

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
    }

    var title: String {
        Localized.Activity.title
    }
    
    var request: TransactionsRequest {
        TransactionsRequest(walletId: walletId.id, type: type)
    }
}

// MARK: - Business Logic

extension TransactionsViewModel {
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
