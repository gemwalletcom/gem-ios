// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol TransferHandleable: Sendable {
    @MainActor
    func handle(state: TransferState) async
}
