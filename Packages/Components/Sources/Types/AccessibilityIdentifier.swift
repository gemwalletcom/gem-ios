// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

public enum AccessibilityIdentifier: String, Identifiable {
    
    case safariInfoButton
    case stateButton
    case doneButton = "Done"
    case cancelButton = "Cancel"
    case floatTextField
    case xCircleCleanButton = "multiply.circle.fill"
    case filterButton
    case tagsView
    case plusButton
    
    public var id: String { rawValue }
}

public extension View {
    func accessibilityIdentifier(_ identifier: AccessibilityIdentifier) -> some View {
        accessibilityIdentifier(identifier.id)
    }
}

// MARK: - IdentifiableView

public extension AccessibilityIdentifier {
    enum IdentifiableView: Identifiable {
        case key(String)
        
        public var id: String {
            switch self {
            case .key(let id): id
            }
        }
    }
}

public extension View {
    func accessibilityIdentifier(_ identifier: AccessibilityIdentifier.IdentifiableView) -> some View {
        accessibilityIdentifier(identifier.id)
    }
}
