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
        guard let type = WalletType(rawValue: wallet.type) else {
            return .none
        }
        return Wallet(
            id: wallet.id,
            name: wallet.name,
            index: wallet.index.asInt32,
            type: type,
            accounts: accounts.map { $0.mapToAccount() },
            order: wallet.order.asInt32,
            isPinned: wallet.isPinned,
            imageUrl: imageUrl()
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

fileprivate extension WalletRecordInfo {
    func imageUrl() -> String? {
        guard let imageUrl = wallet.imageUrl else {
            return nil
        }
        if let url = URL(string: imageUrl), url.scheme != nil {
            return url.absoluteString
        }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(imageUrl).absoluteString
    }
}
