// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives

public struct AvatarService: Sendable {
    private let store: WalletStore
    private let localStore = LocalStore()
    
    public init(store: WalletStore) {
        self.store = store
    }
    
    // MARK: - Store

    public func save(data: Data, for wallet: Wallet) throws {
        try write(data: data, for: wallet)
    }

    public func save(url: URL, for wallet: Wallet) async throws {
        let (data, _) = try await URLSession.shared.data(from: url)
        try write(data: data, for: wallet)
    }

    public func remove(for wallet: Wallet) throws {
        try deleteExistingAvatar(for: wallet)
        try store.setWalletAvatar(wallet.walletId, path: nil)
    }

    // MARK: - Private methods

    private func write(data: Data, for wallet: Wallet) throws {
        try deleteExistingAvatar(for: wallet)

        let imageUrl = try localStore.store(data, id: UUID().uuidString, documentType: "png")
        try store.setWalletAvatar(wallet.walletId, path: imageUrl)
    }

    private func deleteExistingAvatar(for wallet: Wallet) throws {
        guard let avatar = wallet.imageUrl else {
            return
        }
        try localStore.remove(avatar)
    }
}
