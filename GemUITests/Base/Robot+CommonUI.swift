// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import XCTest
import Components

extension Robot {
    var safariInfoButton: XCUIElement {
        app.buttons[AccessibilityIdentifier.safariInfoButton.id]
    }
    var stateButton: XCUIElement {
        app.buttons[AccessibilityIdentifier.stateButton.id]
    }
    var doneButton: XCUIElement {
        app.buttons[AccessibilityIdentifier.doneButton.id]
    }
    var cancelButton: XCUIElement {
        app.buttons[AccessibilityIdentifier.cancelButton.id]
    }
    var searchField: XCUIElement {
        app.searchFields.firstMatch
    }
    var cancelSearchButton: XCUIElement {
        app.navigationBars.buttons[AccessibilityIdentifier.cancelButton.id]
    }
    var alert: XCUIElement {
        app.alerts.firstMatch
    }
    var filterButton: XCUIElement {
        app.buttons[AccessibilityIdentifier.filterButton.id]
    }
    var plusButton: XCUIElement {
        app.buttons[AccessibilityIdentifier.plusButton.id]
    }

    func backButton(title: String) -> XCUIElement {
        app.navigationBars.buttons[title]
    }
}
