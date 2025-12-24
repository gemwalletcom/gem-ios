// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Localization
import Foundation
@testable import Formatters

struct RelativeDateFormatterTests {
    private let formatter = RelativeDateFormatter()

    @Test
    func today() {
        let result = formatter.string(from: Date())
        #expect(result.hasPrefix(Localized.Date.today))
    }

    @Test
    func yesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let result = formatter.string(from: yesterday)
        #expect(result.hasPrefix(Localized.Date.yesterday))
    }

    @Test
    func olderDate() {
        let oldDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let result = formatter.string(from: oldDate)
        #expect(!result.hasPrefix(Localized.Date.today))
        #expect(!result.hasPrefix(Localized.Date.yesterday))
    }
}
