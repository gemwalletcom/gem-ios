// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension Date? {
    func isOutdated(by interval: TimeInterval) -> Bool {
        guard let self else { return true }
        return self.timeIntervalSinceNow < -interval
    }
    
    func isOutdated(byDays days: Int) -> Bool {
        isOutdated(by: TimeInterval(days * 24 * 60 * 60))
    }
}