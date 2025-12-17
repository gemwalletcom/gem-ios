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
    
    func isOutdated(byHours hours: Int) -> Bool {
        isOutdated(by: TimeInterval(hours * 60 * 60))
    }
    
    func isOutdated(byMinutes minutes: Int) -> Bool {
        isOutdated(by: TimeInterval(minutes * 60))
    }
}

public extension Date {
    static func timestamp() -> UInt64 {
        UInt64(Date().timeIntervalSince1970)
    }

    static func timestampInMs() -> UInt64 {
        UInt64(Date().timeIntervalSince1970 * 1000)
    }
}
