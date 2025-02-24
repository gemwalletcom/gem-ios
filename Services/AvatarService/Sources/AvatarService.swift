// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import UIKit

public struct AvatarService: Sendable {
    private let store: WalletStore
    
    public init(store: WalletStore) {
        self.store = store
    }
    
    // MARK: - Store

    @MainActor
    public func save(image: UIImage, for walletId: String) throws {
        guard let data = image.compress() else {
            throw AnyError("Compression image failed")
        }
        
        let path = try preparePath(for: walletId)
        try data.write(to: path, options: .atomic)

        try store.setWalletAvatar(walletId, path: folderPath(for: walletId) + path.lastPathComponent)
    }
    
    public func save(url: URL, for walletId: String) async throws {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let path = try preparePath(for: walletId)
        try data.write(to: path, options: .atomic)

        try store.setWalletAvatar(walletId, path: folderPath(for: walletId) + path.lastPathComponent)
    }
    
    public func remove(for walletId: String) throws {
        let path = try folder(for: walletId)
        try removeIfExist(at: path)
        try store.setWalletAvatar(walletId, path: nil)
    }
    
    // MARK: - FileManager Private Methods
    
    private func preparePath(for walletId: String) throws -> URL {
        try removeIfExist(at: try folder(for: walletId))
        let rootPath = try folder(for: walletId)
        return rootPath.appendingPathComponent(UUID().uuidString + ".png")
    }
    
    private func folder(for walletId: String) throws -> URL {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw AnyError("Unable to fetch URLs for the specified common directory in the requested domains.")
        }
        
        let dataPath = documentsDirectory.appendingPathComponent(folderPath(for: walletId))
        if !FileManager.default.fileExists(atPath: dataPath.path) {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        }
        return dataPath
    }
    
    private func folderPath(for walletId: String) -> String {
        "Avatars/\(walletId)/"
    }
    
    private func removeIfExist(at url: URL) throws {
        if FileManager.default.fileExists(atPath: url.path()) {
            try FileManager.default.removeItem(at: url)
        }
    }
}
