// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
@testable import Transfer

public extension TransferStateService {
    static func mock(presenter: TransferStatePresenter = .mock()) -> TransferStateService {
        TransferStateService(presenter: presenter)
    }
}
