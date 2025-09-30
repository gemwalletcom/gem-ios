// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct GlassEffectSettings : Sendable{
    public static let isInteractive: Self = .init(isEnabled: true, isInteractive: true)
    public static let enabled: Self = .init(isEnabled: true, isInteractive: false)
    public static let disabled: Self = .init(isEnabled: false, isInteractive: false)
    
    public let isEnabled: Bool
    public let isInteractive: Bool
    
    public init(isEnabled: Bool, isInteractive: Bool) {
        self.isEnabled = isEnabled
        self.isInteractive = isInteractive
    }
}
