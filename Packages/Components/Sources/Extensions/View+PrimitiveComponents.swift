// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

extension View {
    @MainActor
    public func presentationDetentsForCurrentDeviceSize(expandable: Bool = false) -> some View {
        switch DeviceSize.current {
        case .small:
            return self.presentationDetents([.large])
        case .medium, .large:
            if expandable {
                return self.presentationDetents([.medium, .large])
            }
            return self.presentationDetents([.medium])
        }
    }
    
    @ViewBuilder
    public func enabled(_ value: Bool) -> some View {
        self.disabled(!value)
    }
}
