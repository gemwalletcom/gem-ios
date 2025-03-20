// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct SyncValues: Sendable {
    
    public enum Primary {
        case local
        case remote
    }
    
    public struct SyncResult<T: Hashable & Sendable> {
        public let missing: Set<T>
        public let delete: Set<T>
    }
    
    public static func changes<T: Hashable & Sendable>(
        primary: Self.Primary,
        local: Set<T>,
        remote: Set<T>
    ) -> SyncResult<T> {
        switch primary {
        case .local:
            SyncResult(
                missing: local.subtracting(remote),
                delete: remote.subtracting(local)
            )
        case .remote:
            SyncResult(
                missing: remote.subtracting(local),
                delete: local.subtracting(remote)
            )
        }
    }
}
