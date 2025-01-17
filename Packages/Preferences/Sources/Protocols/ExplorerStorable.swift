// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public protocol ExplorerPreferencesStorable: Sendable {
    func set(chain: Chain, name: String)
    func get(chain: Chain) -> String?
}
