// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct FileStore: FileStorable {
    private let documentType = "json"
    private var fileManager: FileManager { FileManager.default }
    private let documentDirectory = URL.documentsDirectory
    
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    public init(
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.decoder = decoder
        self.encoder = encoder
    }
    
    // MARK: - Public methods
    
    public func value<T: Decodable>(for key: FileStorageKey) throws -> T? {
        let documentPath = documentPath(for: key)
        guard fileManager.fileExists(atPath: documentPath.path) else {
            return nil
        }

        let data = try Data(contentsOf: documentPath)
        return try decoder.decode(T.self, from: data)
    }

    public func store<T: Encodable>(value: T, for key: FileStorageKey) throws {
        let data = try encoder.encode(value)
        let documentPath = documentPath(for: key)
        try data.write(to: documentPath, options: .atomic)
    }
    
    public func remove(for key: FileStorageKey) throws {
        guard fileManager.fileExists(atPath: documentPath(for: key).path()) else {
            return
        }
        try fileManager.removeItem(at: documentPath(for: key))
    }
    
    // MARK: - Private methods
    
    private func documentPath(for key: FileStorageKey) -> URL {
        documentDirectory
            .appendingPathComponent(key.path)
            .appendingPathExtension(documentType)
    }
}
