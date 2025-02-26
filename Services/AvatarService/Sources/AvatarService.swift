// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import UIKit

public struct AvatarService: Sendable {
    private let store: WalletStore
    private static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    public init(
        store: WalletStore
    ) {
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
        let path = try folderPath(for: walletId)
        try removeIfExist(at: path)
        try store.setWalletAvatar(walletId, path: nil)
    }
    
    // MARK: - Private methods
    
    private func write(data: Data, for walletId: String) throws {
        let path = try preparePath(for: walletId)
        try data.write(to: path, options: .atomic)

        try store.setWalletAvatar(walletId, path: avatarsPath(for: walletId) + path.lastPathComponent)
    }
    
    // MARK: - FileManager Private Methods
    
    private func preparePath(for walletId: String) throws -> URL {
        try removeIfExist(at: try folderPath(for: walletId))
        let rootPath = try folderPath(for: walletId)
        return rootPath.appendingPathComponent(UUID().uuidString + ".png")
    }
    
    private func folderPath(for walletId: String) throws -> URL {
        guard let documentsDirectory = Self.documentsDirectory else {
            throw AnyError("Unable to fetch URLs for the specified common directory in the requested domains.")
        }
        let fileManager = FileManager.default
        let dataPath = documentsDirectory.appendingPathComponent(avatarsPath(for: walletId))
        if !fileManager.fileExists(atPath: dataPath.path) {
            try fileManager.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        }
        return dataPath
    }
    
    private func avatarsPath(for walletId: String) -> String {
        "Avatars/\(walletId)/"
    }
    
    private func removeIfExist(at url: URL) throws {
        if FileManager.default.fileExists(atPath: url.path()) {
            try FileManager.default.removeItem(at: url)
        }
    }
}
