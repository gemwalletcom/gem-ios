// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

struct ConnectionDateFormatter {
    private static let dateAndTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .long
        return formatter
    }()

    private static let time: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    private let date: Date

    public init(date: Date) {
        self.date = date
    }

    var dateString: String {
        if Calendar.current.isDateInToday(date) {
            return String(format: "%@, %@", Localized.Date.today, Self.time.string(from: date))
        } else if Calendar.current.isDateInYesterday(date) {
            return String(format: "%@, %@", Localized.Date.yesterday, Self.time.string(from: date))
        }
        return Self.dateAndTime.string(from: date)
    }
}

