// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
@testable import Transfer

public struct TransferHandlerMock: TransferHandleable {
    public init() {}

    public func handle(state: TransferState) async {}
}
