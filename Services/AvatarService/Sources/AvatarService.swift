// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import UIKit
import FileStore

public struct AvatarService: Sendable {
    private let store: WalletStore
    private let fileStore: FileStore
    
    public init(
        store: WalletStore,
        fileStore: FileStore
    ) {
        self.store = store
        self.fileStore = fileStore
    }
    
    // MARK: - Store

    public func save(image: UIImage, for walletId: String) throws {
        guard let data = image.compress() else {
            throw AnyError("Compression image failed")
        }
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
        
        let avatarId = UUID().uuidString
        try fileStore.store(value: data, for: .avatar(walletId: walletId, avatarId: avatarId))
        try store.setWalletAvatar(walletId, path: avatarId)
    }
    
    private func deleteExistingAvatar(for walletId: String) throws {
        guard let imagePath = try store.getWallet(id: walletId)?.imageUrl else {
            return
        }
        try fileStore.remove(for: .avatar(walletId: walletId, avatarId: imagePath))
    }
}
