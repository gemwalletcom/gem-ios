// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import UIKit

public struct AvatarService: Sendable {
    private let store: WalletStore
    
    private let documentType = "png"
    private let avatarsFolder = URL(filePath: "Avatars")
    private var fileManager: FileManager { FileManager.default }
    private var documentDirectory: URL { URL.documentsDirectory }
    
    public init(store: WalletStore) {
        self.store = store
    }
    
    // MARK: - Store

    @MainActor
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
        try removeIfExist(for: walletId)
        try store.setWalletAvatar(walletId, path: nil)
    }
    
    // MARK: - Private methods
    
    private func write(data: Data, for walletId: String) throws {
        let avatarPath = avatarPath(for: walletId)
        let fullPath = documentDirectory.appending(path: avatarPath.path())
        try removeIfExist(for: walletId)
        
        try createDirectory(for: fullPath.deletingLastPathComponent())
        try data.write(to: fullPath, options: .atomic)
        try store.setWalletAvatar(walletId, path: avatarPath.path())
    }
    
    private func avatarPath(for walletId: String) -> URL {
        avatarsFolder
            .appendingPathComponent(walletId)
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(documentType)
    }
    
    // MARK: - FileManager Private Methods

    private func createDirectory(for path: URL) throws {
        guard !fileManager.fileExists(atPath: path.path, isDirectory: nil) else {
            return
        }
        try fileManager.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
    }
    
    private func removeIfExist(for walletId: String) throws {
        guard
            let imageUrl = try store.getWallet(id: walletId)?.imageUrl,
            FileManager.default.fileExists(atPath: documentDirectory.appending(path: imageUrl).path())
        else {
            return
        }
        try FileManager.default.removeItem(at: documentDirectory.appending(path: imageUrl))
    }
}
