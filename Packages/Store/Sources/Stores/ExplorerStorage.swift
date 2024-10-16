// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct ExplorerStorage: ExplorerStorable {
    
    private let preferences: Preferences
    
    public init(preferences: Preferences) {
        self.preferences = preferences
    }
    
    public func set(chain: Chain, name: String) {
        preferences.setExplorerName(chain: chain, name: name)
    }
    
    public func get(chain: Chain) -> String? {
        preferences.explorerName(chain: chain)
    }
}
