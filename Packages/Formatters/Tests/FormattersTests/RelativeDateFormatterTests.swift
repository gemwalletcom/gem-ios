// Copyright (c). Gem Wallet. All rights reserved.

@testable import Formatters
import Foundation
import Testing

struct RelativeDateFormatterTests {
    private let locale = Locale(identifier: "en_US")
    private let timeZone = TimeZone(identifier: "America/New_York")!
    private let formatter: RelativeDateFormatter
    private let calendar: Calendar

    init() {
        formatter = RelativeDateFormatter(locale: locale, timeZone: timeZone)
        var calendar = Calendar.current
        calendar.locale = locale
        calendar.timeZone = timeZone
        self.calendar = calendar
    }

    @Test
    func today() throws {
        let todayWithTime = try #require(calendar.date(bySettingHour: 14, minute: 30, second: 0, of: Date()))

        #expect(formatter.string(from: todayWithTime) == "Today, 2:30 PM")
    }

    @Test
    func yesterday() throws {
        let yesterdayDate = try #require(calendar.date(byAdding: .day, value: -1, to: Date()))
        let yesterdayWithTime = try #require(calendar.date(bySettingHour: 9, minute: 15, second: 0, of: yesterdayDate))

        #expect(formatter.string(from: yesterdayWithTime) == "Yesterday, 9:15 AM")
    }

    @Test
    func oneMonthOld() throws {
        var components = DateComponents()
        components.year = 2025
        components.month = 2
        components.day = 2
        components.hour = 10
        components.minute = 25
        components.timeZone = timeZone
        let date = try #require(calendar.date(from: components))

        #expect(formatter.string(from: date) == "February 2, 2025 at 10:25 AM")
    }
}
