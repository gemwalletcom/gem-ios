// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct LocalStore: Sendable {
    private let documentType = "png"
    private var fileManager: FileManager { FileManager.default }
    private let documentDirectory = URL.documentsDirectory
    
    // MARK: - Public methods

    public func store(_ data: Data) throws -> String {
        let documentPath = documentPath(for: UUID().uuidString)
        try data.write(to: documentPath, options: .atomic)
        return documentPath.lastPathComponent
    }
    
    public func remove(_ avatar: String) throws {
        guard fileManager.fileExists(atPath: documentPath(for: avatar).path()) else {
            return
        }
        try fileManager.removeItem(at: documentPath(for: avatar))
    }
    
    // MARK: - Private methods
    
    private func documentPath(for id: String) -> URL {
        var path = documentDirectory.appendingPathComponent(id)
        if path.pathExtension.isEmpty {
            path = path.appendingPathExtension(documentType)
        }
        return path
    }
}
