// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Validators

@MainActor
struct AutocloseInput {
    var takeProfit: InputValidationViewModel
    var stopLoss: InputValidationViewModel
    var focusField: AutocloseScene.Field?

    init(type: AutocloseType, takeProfitText: String?, stopLossText: String?) {
        self.takeProfit = InputValidationViewModel(
            mode: .manual,
            validators: [AutocloseValidator(type: .takeProfit, marketPrice: type.marketPrice, direction: type.direction)]
        )
        self.stopLoss = InputValidationViewModel(
            mode: .manual,
            validators: [AutocloseValidator(type: .stopLoss, marketPrice: type.marketPrice, direction: type.direction)]
        )

        takeProfitText.map { self.takeProfit.text = $0 }
        stopLossText.map { self.stopLoss.text = $0 }
    }

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
