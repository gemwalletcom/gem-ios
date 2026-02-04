// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct RelativeDateFormatter: Sendable {
    private static let relativeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

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

    public func string(from date: Date) -> String {
        if Calendar.current.isDateInToday(date) || Calendar.current.isDateInYesterday(date) {
            let relativeDate = Self.relativeFormatter.string(from: date)
            return String(format: "%@, %@", relativeDate, Self.time.string(from: date))
        }
        return Self.dateAndTime.string(from: date)
    }
}
