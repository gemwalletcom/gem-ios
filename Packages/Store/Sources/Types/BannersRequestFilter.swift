// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public enum BannersRequestFilter: Sendable, Equatable, Hashable {
    case asset(id: AssetId)
    case excludeActiveStaking
}