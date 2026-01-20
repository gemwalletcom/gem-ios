// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public enum AppIcon: String, CaseIterable, Identifiable, Sendable, Hashable {
    case primary
    case mono = "AppIcon-Mono"
    case lava = "AppIcon-Lava"

    public init(_ rawValue: String?) {
        self = rawValue.flatMap { Self(rawValue: $0) } ?? .primary
    }

    public var id: String { rawValue }

    public var iconName: String? {
        switch self {
        case .primary: nil
        default: rawValue
        }
    }
}
