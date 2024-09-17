// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum LockOption: Int {
    case immediate = 0
    case oneMinute = 60
    case fiveMinutes = 300
    case oneHour = 3600
    case sixHours = 21600
}

extension LockOption: CaseIterable {}
extension LockOption: Identifiable, Hashable {
    var id: Int { rawValue }
}
