// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import XCUIAutomation
import XCTest

extension XCUIElement {
    func clearAndEnterText(text: String) {
        guard let stringValue = value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        
        tap()
        typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count))
        typeText(text)
    }
}
