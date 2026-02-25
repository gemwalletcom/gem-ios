// Copyright (c). Gem Wallet. All rights reserved.

import Components
import Primitives
import Style

extension NameProvider {
    public var assetImage: AssetImage? {
        switch self {
        case .ens, .basenames: .image(Images.NameResolve.ens)
        case .aptos: .image(Images.Chains.aptos)
        case .injective: .image(Images.Chains.injective)
        case .ud, .sns, .spaceid, .lens, .ton, .tree, .eths, .did, .suins, .icns, .hyperliquid, .allDomains: nil
        }
    }
}
