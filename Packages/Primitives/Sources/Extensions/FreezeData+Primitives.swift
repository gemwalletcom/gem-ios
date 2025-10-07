// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension FreezeData {
    func with(resource: Resource) -> FreezeData {
        FreezeData(
            freezeType: freezeType,
            resource: resource
        )
    }
}
