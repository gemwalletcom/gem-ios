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

    public func save(data: Data, for walletId: String) throws {
        try write(data: data, for: walletId)
    }
    
    public func save(url: URL, for walletId: String) async throws {
        let (data, _) = try await URLSession.shared.data(from: url)
        try write(data: data, for: walletId)
    }
    
    public func remove(for walletId: String) throws {
        try deleteExistingAvatar(for: walletId)
        try store.setWalletAvatar(walletId, path: nil)
    }
    
    // MARK: - Private methods
    
    private func write(data: Data, for walletId: String) throws {
        try deleteExistingAvatar(for: walletId)
        
        let imageUrl = try localStore.store(data, id: UUID().uuidString, documentType: "png")
        try store.setWalletAvatar(walletId, path: imageUrl)
    }
    
    private func deleteExistingAvatar(for walletId: String) throws {
        guard let avatar = try store.getWallet(id: walletId)?.imageUrl else {
            return
        }
        try localStore.remove(avatar)
    }
}
