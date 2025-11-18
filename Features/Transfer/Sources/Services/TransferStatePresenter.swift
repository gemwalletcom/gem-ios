// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives

@Observable
public final class TransferStatePresenter: Sendable {

    @MainActor
    public var executions: [TransferExecution] = []

    public init() {}
}

public extension Array where Element == TransferExecution {
    var displayExecution: TransferExecution? {
        sorted { $0.state.priority > $1.state.priority }.first
    }
}
