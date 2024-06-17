// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol ExplorerStorable {
    func set(chain: Chain, name: String)
    func get(chain: Chain) -> String?
}
