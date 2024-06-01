// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Store
import GRDB
import GRDBQuery

struct TransactionsViewModel {
    
    let wallet: Wallet
    let type: TransactionsRequestType
    let preferences: SecurePreferences = .standard
    let service: TransactionsService
    
    var title: String {
        //TODO: Change Title based on the type
        return Localized.Activity.title
    }
    
    var request: TransactionsRequest {
        return TransactionsRequest(walletId: wallet.id, type: type)
    }
    
    func fetch() async {
        do {
            guard let deviceId = try preferences.get(key: .deviceId) else {
                throw AnyError("deviceId is null")
            }
            try await service.updateAll(deviceId: deviceId, wallet: wallet)
        } catch {
            NSLog("fetch getTransactions error \(error)")
        }
    }
}
