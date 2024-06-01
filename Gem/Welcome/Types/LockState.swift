// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum LockState {
    case locked
    case unlocked
}

class LockStateService: ObservableObject {
    
    @Published var state: LockState
    
    public init(
        state: LockState
    ) {
        self.state = state
    }
}
