// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public final class ConfigPreferences: @unchecked Sendable {
    public static let standard = ConfigPreferences()

    private struct Keys {
        static let config = "config"
    }

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    @CodableDefaults(key: Keys.config)
    public var config: ConfigResponse?
}
