// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

public struct AlertMessage: Identifiable, Sendable {
    public var id: String { (title ?? "") + message + actions.map(\.title).joined() }
    
    public let title: String?
    public let message: String
    public let actions: [AlertAction]
    
    public init(
        title: String? = nil,
        message: String,
        actions: [AlertAction] = []
    ) {
        self.title = title
        self.message = message
        self.actions = actions
    }
}

public struct AlertAction: Sendable {
    public let title: String
    public let role: ButtonRole?
    public let action: @Sendable () -> Void
    
    public init(
        title: String,
        role: ButtonRole? = nil,
        action: @escaping @Sendable () -> Void = {}
    ) {
        self.title = title
        self.role = role
        self.action = action
    }
}

public extension AlertAction {
    static func cancel(title: String) -> AlertAction {
        AlertAction(title: title, role: .cancel)
    }
}