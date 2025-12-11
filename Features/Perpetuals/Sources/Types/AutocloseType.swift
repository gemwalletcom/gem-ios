// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemstonePrimitives
import PrimitivesComponents

public typealias AutocloseCompletion = (_ takeProfit: InputValidationViewModel, _ stopLoss: InputValidationViewModel) -> Void

public enum AutocloseType {
    case modify(PerpetualPositionData, onTransferAction: TransferDataAction)
    case open(AutocloseOpenData, onComplete: AutocloseCompletion)
}

extension AutocloseType {
    var marketPrice: Double {
        switch self {
        case .modify(let position, _): position.perpetual.price
        case .open(let data, _): data.marketPrice
        }
    }

    var direction: PerpetualDirection {
        switch self {
        case .modify(let position, _): position.position.direction
        case .open(let data, _): data.direction
        }
    }
}
