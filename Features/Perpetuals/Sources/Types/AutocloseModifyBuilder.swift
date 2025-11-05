// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct AutocloseModifyBuilder {
    private let position: PerpetualPositionData

    init(position: PerpetualPositionData) {
        self.position = position
    }

    func canBuild(takeProfit: AutocloseField, stopLoss: AutocloseField) -> Bool {
        let hasChanges = takeProfit.shouldUpdate || stopLoss.shouldUpdate
        let takeProfitValid = takeProfit.price == nil || takeProfit.isValid
        let stopLossValid = stopLoss.price == nil || stopLoss.isValid

        return hasChanges && takeProfitValid && stopLossValid
    }

    func build(
        assetIndex: Int32,
        takeProfit: AutocloseField,
        stopLoss: AutocloseField
    ) -> [PerpetualModifyPositionType] {
        var result: [PerpetualModifyPositionType] = []

        let cancelOrders = buildCancelOrders(
            assetIndex: assetIndex,
            takeProfit: takeProfit,
            stopLoss: stopLoss
        )

        if !cancelOrders.isEmpty {
            result.append(.cancel(cancelOrders))
        }

        if takeProfit.shouldSet || stopLoss.shouldSet {
            result.append(buildTPSL(takeProfit: takeProfit, stopLoss: stopLoss))
        }

        return result
    }
}

// MARK: - Private

extension AutocloseModifyBuilder {
    private func buildTPSL(takeProfit: AutocloseField, stopLoss: AutocloseField) -> PerpetualModifyPositionType {
        .tpsl(TPSLOrderData(
            direction: position.position.direction,
            takeProfit: takeProfit.shouldSet ? takeProfit.formattedPrice : nil,
            stopLoss: stopLoss.shouldSet ? stopLoss.formattedPrice : nil,
            size: .zero
        ))
    }

    private func buildCancelOrders(
        assetIndex: Int32,
        takeProfit: AutocloseField,
        stopLoss: AutocloseField
    ) -> [CancelOrderData] {
        [takeProfit, stopLoss].compactMap { field in
            guard field.shouldCancel, let orderId = field.orderId else { return nil }
            return CancelOrderData(assetIndex: assetIndex, orderId: orderId)
        }
    }
}
