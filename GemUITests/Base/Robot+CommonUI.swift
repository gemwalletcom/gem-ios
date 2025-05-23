// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import XCUIAutomation
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

    func backButton(title: String) -> XCUIElement {
        app.navigationBars.buttons[title]
    }
}
