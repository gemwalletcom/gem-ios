// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum CloudSyncError: Error, Sendable {
    case invalidRecordData
    case encryptionFailed
}
