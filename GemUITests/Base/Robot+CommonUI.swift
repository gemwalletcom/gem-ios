// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import XCTest
import Components

extension Robot {
    var safariInfoButton: XCUIElement {
        app.buttons[AccessibilityIdentifier.Common.safariInfoButton.id]
    }
    var stateButton: XCUIElement {
        app.buttons[AccessibilityIdentifier.Common.stateButton.id]
    }
    var doneButton: XCUIElement {
        app.buttons[AccessibilityIdentifier.Common.doneButton.id]
    }
    var cancelButton: XCUIElement {
        app.buttons[AccessibilityIdentifier.Common.cancelButton.id]
    }
    var searchField: XCUIElement {
        app.searchFields.firstMatch
    }
    var cancelSearchButton: XCUIElement {
        app.navigationBars.buttons[AccessibilityIdentifier.Common.cancelButton.id]
    }
    var alert: XCUIElement {
        app.alerts.firstMatch
    }

    func backButton(title: String) -> XCUIElement {
        app.navigationBars.buttons[title]
    }
}
