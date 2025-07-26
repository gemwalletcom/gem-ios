// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct SyncDiff: Sendable {
    
    public enum Primary {
        case local
        case remote
    }
    
    public struct Result<T: Hashable & Sendable> {
        public let toAdd: Set<T>
        public let toDelete: Set<T>
    }
    
    public static func calculate<T: Hashable & Sendable>(
        primary: Primary,
        local: Set<T>,
        remote: Set<T>
    ) -> Result<T> {
        switch primary {
        case .local:
            return Result(
                toAdd: local.subtracting(remote),
                toDelete: remote.subtracting(local)
            )
        case .remote:
            return Result(
                toAdd: remote.subtracting(local),
                toDelete: local.subtracting(remote)
            )
        }
    }
}