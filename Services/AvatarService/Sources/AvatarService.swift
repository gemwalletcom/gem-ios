// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import UIKit

public struct AvatarService: Sendable {
    private let store: AvatarStore
    
    public init(store: AvatarStore) {
        self.store = store
    }
    
    // MARK: - Store

    public func save(image: UIImage, walletId: String) throws {
        guard
            let resizedImage = image.resizeImageAspectFit(targetWidth: 128),
            let data = resizedImage.compress(.high)
        else {
            throw AnyError("Compression image failed")
        }
        
        let path = try preparePath(for: walletId)
        try writeData(data, to: path)
        try save(AvatarValue(url: path), for: walletId)
    }
    
    public func save(url: URL, walletId: String) async throws {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let path = try preparePath(for: walletId)
        try writeData(data, to: path)
        try save(AvatarValue(url: path), for: walletId)
    }
    
    public func remove(for walletId: String) throws {
        let path = try folder(for: walletId)
        try removeIfExist(at: path)
        try store.remove(for: walletId)
    }
    
    // MARK: - Private methods

    private func save(_ avatar: AvatarValue, for walletId: String) throws {
        try store.save(avatar, for: walletId)
    }
    
    private func preparePath(for walletId: String) throws -> URL {
        try removeIfExist(at: try folder(for: walletId))
        let rootPath = try folder(for: walletId)
        return rootPath.appendingPathComponent(UUID().uuidString + ".jpg")
    }
    
    private func folder(for walletId: String) throws -> URL {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw AnyError("Unable to fetch URLs for the specified common directory in the requested domains.")
        }
        
        let dataPath = documentsDirectory.appendingPathComponent("Avatars/\(walletId)")
        if !FileManager.default.fileExists(atPath: dataPath.path) {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        }
        return dataPath
    }
    
    private func writeData(_ data: Data, to url: URL) throws {
        try data.write(to: url)
    }
    
    private func removeIfExist(at url: URL) throws {
        if FileManager.default.fileExists(atPath: url.path()) {
            try FileManager.default.removeItem(at: url)
        }
    }
}
