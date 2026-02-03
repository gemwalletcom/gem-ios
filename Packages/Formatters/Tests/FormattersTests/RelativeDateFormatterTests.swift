// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Foundation
@testable import Formatters

struct RelativeDateFormatterTests {
    private let formatter = RelativeDateFormatter()

    @Test
    func today() {
        let calendar = Calendar.current
        let todayWithTime = calendar.date(bySettingHour: 14, minute: 30, second: 0, of: Date())!

        #expect(formatter.string(from: todayWithTime) == "Today, 2:30 PM")
    }

    @Test
    func yesterday() {
        let calendar = Calendar.current
        let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: Date())!

        let yesterdayWithTime = calendar.date(bySettingHour: 9, minute: 15, second: 0, of: yesterdayDate)!
        #expect(formatter.string(from: yesterdayWithTime) == "Yesterday, 9:15 AM")
    }

    @Test
    func oneMonthOld() {
        var components = DateComponents()
        components.year = 2025
        components.month = 2
        components.day = 2
        components.hour = 10
        components.minute = 25
        let date = Calendar.current.date(from: components)!

        #expect(formatter.string(from: date) == "February 2, 2025 at 10:25 AM")
    }
}
