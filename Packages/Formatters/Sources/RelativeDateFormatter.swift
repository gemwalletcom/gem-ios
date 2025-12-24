// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization

public struct RelativeDateFormatter: Sendable {
    private static let time: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    private static let dateAndTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .long
        return formatter
    }()

    private static let dateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .long
        return formatter
    }()

    public init() {}

    public func string(from date: Date, includeTime: Bool = true) -> String {
        if Calendar.current.isDateInToday(date) {
            return String(format: "%@, %@", Localized.Date.today, Self.time.string(from: date))
        } else if Calendar.current.isDateInYesterday(date) {
            return String(format: "%@, %@", Localized.Date.yesterday, Self.time.string(from: date))
        }
        return includeTime ? Self.dateAndTime.string(from: date) : Self.dateOnly.string(from: date)
    }
}
