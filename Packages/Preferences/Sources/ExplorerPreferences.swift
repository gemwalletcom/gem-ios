// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct ExplorerPreferences: Sendable {
    private let preferences: Preferences
    
    public init(preferences: Preferences = .standard) {
        self.preferences = preferences
    }
}

// MARK: - ExplorerPreferencesStorable

extension ExplorerPreferences: ExplorerPreferencesStorable {
    public func set(chain: Chain, name: String) {
        preferences.setExplorerName(chain: chain, name: name)
    }

    public func get(chain: Chain) -> String? {
        preferences.explorerName(chain: chain)
    }
}
