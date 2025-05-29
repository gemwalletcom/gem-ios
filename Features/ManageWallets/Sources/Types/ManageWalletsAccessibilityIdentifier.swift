// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

enum ManageWalletsAccessibilityIdentifier: String, Identifiable {
    case manageWalletsCreateButton
    case manageWalletsImportButton

    var id: String { rawValue }
}

extension View {
    func accessibilityIdentifier(_ identifier: ManageWalletsAccessibilityIdentifier) -> some View {
        accessibilityIdentifier(identifier.id)
    }
}
