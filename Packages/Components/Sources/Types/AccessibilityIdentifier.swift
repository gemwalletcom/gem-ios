// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUICore

public enum AccessibilityIdentifier: String, Identifiable {
    
    case safariInfoButton
    case stateButton
    case doneButton = "Done"
    case cancelButton = "Cancel"
    case floatTextField
    case xCircleCleanButton = "multiply.circle.fill"
    
    public var id: String { rawValue }
}

public extension View {
    func accessibilityIdentifier(_ identifier: AccessibilityIdentifier) -> some View {
        accessibilityIdentifier(identifier.id)
    }
}
