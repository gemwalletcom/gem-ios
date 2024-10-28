// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public final class MockExplorerStorage: ExplorerStorable, @unchecked Sendable {
    
    private var map: [Chain: String] = [:]
    
    public init(map: [Chain : String] = [:]) {
        self.map = map
    }
    
    public func set(chain: Chain, name: String) {
        map[chain] = name
    }
    
    public func get(chain: Chain) -> String? {
        map[chain]
    }
}
