// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol WalletSessionManageableThrowing: Sendable {
    func getWallets() throws -> [Wallet]
    func getWallet(walletId: WalletId) throws -> Wallet
    func getCurrentWallet() throws -> Wallet
    func getCurrentWalletId() throws -> WalletId
}

public protocol WalletSessionManageable: WalletSessionManageableThrowing {
    var wallets: [Wallet] { get }
    var currentWallet: Wallet? { get }
    var currentWalletId: WalletId? { get }

    func setCurrent(index: Int)
    func setCurrent(walletId: WalletId?)
}

public extension WalletSessionManageable {
    var wallets: [Wallet] {
        do {
            return try getWallets()
        } catch {
            NSLog("get wallets error: \(error)")
            return []
        }
    }

    func getCurrentWallet() throws -> Wallet {
        guard let currentWallet else {
            throw WalletSessionServiceError.noWallet
        }
        return currentWallet
    }

    func getCurrentWalletId() throws -> WalletId {
        guard let currentWalletId else {
            throw WalletSessionServiceError.noWalletId
        }
        return currentWalletId
    }

    func getWallet(walletId: WalletId) throws -> Wallet {
        guard let wallet = wallets.first(where: { $0.walletId == walletId }) else {
            throw WalletSessionServiceError.noWalletId
        }
        return wallet
    }
}
