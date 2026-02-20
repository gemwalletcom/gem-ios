// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import CryptoKit

public struct EncryptedTransformer: DataTransformable {
    private let key: SymmetricKey

    public init(key: SymmetricKey) {
        self.key = key
    }

    public func transform(_ data: Data) throws -> Data {
        guard let combined = try AES.GCM.seal(data, using: key).combined else {
            throw CloudSyncError.encryptionFailed
        }
        return combined
    }

    public func restore(_ data: Data) throws -> Data {
        try AES.GCM.open(try AES.GCM.SealedBox(combined: data), using: key)
    }
}
