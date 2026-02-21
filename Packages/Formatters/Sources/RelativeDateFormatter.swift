// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct RelativeDateFormatter: Sendable {
    let relativeFormatter: DateFormatter
    let time: DateFormatter
    let dateAndTime: DateFormatter
    let calendar: Calendar

    public init(locale: Locale = .current, timeZone: TimeZone = .current) {
        var calendar = Calendar.current
        calendar.locale = locale
        calendar.timeZone = timeZone
        self.calendar = calendar

        relativeFormatter = {
            let formatter = DateFormatter()
            formatter.timeStyle = .none
            formatter.dateStyle = .medium
            formatter.doesRelativeDateFormatting = true
            formatter.locale = locale
            formatter.timeZone = timeZone
            return formatter
        }()

        time = {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            formatter.locale = locale
            formatter.timeZone = timeZone
            return formatter
        }()

        dateAndTime = {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .long
            formatter.locale = locale
            formatter.timeZone = timeZone
            return formatter
        }()
    }

    public func string(from date: Date) -> String {
        if calendar.isDateInToday(date) || calendar.isDateInYesterday(date) {
            let relativeDate = relativeFormatter.string(from: date)
            return String(format: "%@, %@", relativeDate, time.string(from: date))
        }
        return dateAndTime.string(from: date)
    }
}
