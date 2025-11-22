// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension PerpetualType {
    static func mockOpen(
        data: PerpetualConfirmData = .mock()
    ) -> PerpetualType {
        .open(data)
    }

    static func mockClose(
        data: PerpetualConfirmData = .mock()
    ) -> PerpetualType {
        .close(data)
    }

    static func mockIncrease(
        data: PerpetualConfirmData = .mock()
    ) -> PerpetualType {
        .increase(data)
    }

    static func mockReduce(
        data: PerpetualReduceData = .mock()
    ) -> PerpetualType {
        .reduce(data)
    }

    static func mockModify(
        data: PerpetualModifyConfirmData = .mock()
    ) -> PerpetualType {
        .modify(data)
    }
}
