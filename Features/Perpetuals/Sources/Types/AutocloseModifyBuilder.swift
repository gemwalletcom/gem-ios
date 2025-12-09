// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct AutocloseModifyBuilder {
    private let direction: PerpetualDirection

    init(direction: PerpetualDirection) {
        self.direction = direction
    }

    func canBuild(type: AutocloseType, takeProfit: AutocloseField, stopLoss: AutocloseField) -> Bool {
        let takeProfitValid = takeProfit.price == nil || takeProfit.isValid
        let stopLossValid = stopLoss.price == nil || stopLoss.isValid
        guard takeProfitValid && stopLossValid else { return false }

        switch type {
        case .modify:
            return takeProfit.shouldUpdate || stopLoss.shouldUpdate
        case .open:
            return takeProfit.isValid || stopLoss.isValid
        }
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
            direction: direction,
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
