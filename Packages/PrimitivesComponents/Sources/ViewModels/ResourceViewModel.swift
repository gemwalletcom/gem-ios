// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

public struct ResourceViewModel: Hashable, Identifiable {
    public let resource: Resource

    public init(resource: Resource) {
        self.resource = resource
    }

    public var title: String {
        switch resource {
        case .bandwidth: Localized.Stake.Resource.bandwidth
        case .energy: Localized.Stake.Resource.energy
        }
    }

    public var id: Resource { resource }

}
