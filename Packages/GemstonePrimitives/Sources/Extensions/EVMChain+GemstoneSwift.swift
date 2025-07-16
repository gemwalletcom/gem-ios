// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import class Gemstone.Config
import Primitives

extension EVMChain {
    public var isOpStack: Bool {
        Config.shared.getEvmChainConfig(chain: self.rawValue).isOpstack
    }
}
