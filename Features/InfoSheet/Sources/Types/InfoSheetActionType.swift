// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum InfoSheetActionType: Identifiable, Sendable, Equatable {
    case enablePushNotifications

    public var id: String {
        switch self {
        case .enablePushNotifications: "enablePushNotifications"
        }
    }
}
