// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

extension XCUIApplication {

    func acceptTerms() {
        switches.allElementsBoundByIndex.forEach { $0.tap() }
        buttons["Agree and Continue"].firstMatch.tap()
    }

    func tapContinue() {
        buttons["Continue"].firstMatch.tap()
    }

    func getWords() -> [String] {
        (0..<12).map { staticTexts["word_\($0)"].label }
    }
}
