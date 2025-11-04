// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

struct WalletRecordInfo: FetchableRecord, Codable {
    var wallet: WalletRecord
    var accounts: [AccountRecord]
}

extension WalletRecordInfo {
    func mapToWallet() -> Wallet? {
        return Wallet(
            id: wallet.id,
            name: wallet.name,
            index: wallet.index.asInt32,
            type: wallet.type,
            accounts: accounts.map { $0.mapToAccount() },
            order: wallet.order.asInt32,
            isPinned: wallet.isPinned,
            imageUrl: wallet.imageUrl
        )
    }
}

struct WalletConnectionInfo: FetchableRecord, Codable {
    var wallet: WalletRecord
    var connection: WalletConnectionRecord
}

extension WalletConnectionInfo {
    func mapToWalletConnection() -> WalletConnection {
        return WalletConnection(
            session: connection.session,
            wallet: wallet.mapToWallet()
        )
    }
}
