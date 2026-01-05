// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension PerpetualRecipientData {
    static func mock(
        recipient: RecipientData = .mock(),
        positionAction: PerpetualPositionAction = .open(.mock())
    ) -> PerpetualRecipientData {
        PerpetualRecipientData(
            recipient: recipient,
            positionAction: positionAction
        )
    }
}
