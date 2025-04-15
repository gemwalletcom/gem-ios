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
        let (primarySet, secondarySet): (Set<T>, Set<T>) = {
            switch primary {
            case .local:
                return (local, remote)
            case .remote:
                return (remote, local)
            }
        }()

        return SyncResult(
            missing: primarySet.subtracting(secondarySet),
            delete: secondarySet.subtracting(primarySet)
        )
    }
}
