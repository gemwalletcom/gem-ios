// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct GlassEffectSettings : Sendable{
    /// Enabled and interactive (default behavior)
    public static let isInteractive: Self = .init(isEnabled: true, isInteractive: true)
    /// Enabled but not interactive (display only)
    public static let enabled: Self = .init(isEnabled: true, isInteractive: false)
    /// Disabled
    public static let disabled: Self = .init(isEnabled: false, isInteractive: false)
    
    public let isEnabled: Bool
    public let isInteractive: Bool
    
    public init(isEnabled: Bool, isInteractive: Bool) {
        self.isEnabled = isEnabled
        self.isInteractive = isInteractive
    }
}
