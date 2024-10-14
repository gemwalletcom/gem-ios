// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization

public struct TransactionDateFormatter {
    
    private static let sectionFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .long
        return formatter
    }()
    
    private static let rowFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .long
        return formatter
    }()
    private static let rowTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
    
    private let date: Date
    
    public init(date: Date) {
        self.date = date
    }
    
    var section: String {
        if Calendar.current.isDateInToday(date) {
            return Localized.Date.today
        } else if Calendar.current.isDateInYesterday(date) {
            return Localized.Date.yesterday
        }
        return Self.sectionFormatter.string(from: date)
    }
    
    var row: String {
        if Calendar.current.isDateInToday(date) {
            return String(format: "%@, %@", Localized.Date.today, Self.rowTimeFormatter.string(from: date))
        } else if Calendar.current.isDateInYesterday(date) {
            return String(format: "%@, %@", Localized.Date.yesterday, Self.rowTimeFormatter.string(from: date))
        }
        return Self.rowFormatter.string(from: date)
    }
}
