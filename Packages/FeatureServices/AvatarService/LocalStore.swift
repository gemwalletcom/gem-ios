// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct LocalStore: Sendable {
    private var fileManager: FileManager { FileManager.default }
    private let documentDirectory = URL.documentsDirectory
    
    // MARK: - Public methods

    public func store(_ data: Data, id: String, documentType: String) throws -> String {
        let documentPath = documentPath(for: id, documentType: documentType)
        try data.write(to: documentPath, options: .atomic)
        return documentPath.lastPathComponent
    }
    
    public func remove(_ imageUrl: String) throws {
        guard fileManager.fileExists(atPath: documentPath(for: imageUrl, documentType: nil).path()) else {
            return
        }
        try fileManager.removeItem(at: documentPath(for: imageUrl, documentType: nil))
    }
    
    // MARK: - Private methods
    
    private func documentPath(for id: String, documentType: String?) -> URL {
        let path = documentDirectory.appendingPathComponent(id)
        if path.pathExtension.isEmpty, let documentType {
            return path.appendingPathExtension(documentType)
        }
        return path
    }
}
