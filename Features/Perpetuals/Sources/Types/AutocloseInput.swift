// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents

@MainActor
struct AutocloseInput {
    var takeProfit: InputValidationViewModel
    var stopLoss: InputValidationViewModel
    var focusField: AutocloseScene.Field?

    var focused: InputValidationViewModel? {
        switch focusField {
        case .takeProfit: takeProfit
        case .stopLoss: stopLoss
        case nil: nil
        }
    }

    var focusedType: TpslType? {
        switch focusField {
        case .takeProfit: .takeProfit
        case .stopLoss: .stopLoss
        case nil: nil
        }
    }

    func field(
        type: TpslType,
        price: Double?,
        originalPrice: Double?,
        formattedPrice: String?,
        orderId: UInt64?
    ) -> AutocloseField {
        let input = type == .takeProfit ? takeProfit : stopLoss
        return AutocloseField(
            price: price,
            originalPrice: originalPrice,
            formattedPrice: formattedPrice,
            isValid: price != nil && input.isValid,
            orderId: orderId
        )
    }

    func update() {
        takeProfit.update()
        stopLoss.update()
    }
}
