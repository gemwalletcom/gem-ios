// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesTestKit

@testable import Perpetuals

extension AutocloseType {
    static func mockModify(
        position: PerpetualPositionData = .mock()
    ) -> AutocloseType {
        .modify(position, onTransferAction: { _ in })
    }

    static func mockOpen(
        data: AutocloseOpenData = .mock()
    ) -> AutocloseType {
        .open(data, onComplete: { _, _ in })
    }
}
