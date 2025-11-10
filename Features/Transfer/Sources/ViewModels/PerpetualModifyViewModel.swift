// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives
import Formatters
import Components

public struct PerpetualModifyViewModel: Sendable {
    private let data: PerpetualModifyConfirmData
    private let autocloseFormatter = AutocloseFormatter()

    public init(data: PerpetualModifyConfirmData) {
        self.data = data
    }

    public var listItemModel: ListItemModel {
        let canceledOrderIds = Set(
            data.modifyTypes
                .compactMap { if case .cancel(let orders) = $0 { return orders } else { return nil } }
                .flatMap { $0.map(\.orderId) }
        )

        let tpslOrderData = data.modifyTypes.compactMap {
            if case .tpsl(let orderData) = $0 { return orderData }
            return nil
        }.first

        let tpCanceled = data.takeProfitOrderId.map { canceledOrderIds.contains($0) } ?? false
        let slCanceled = data.stopLossOrderId.map { canceledOrderIds.contains($0) } ?? false

        let takeProfit = tpslOrderData?.takeProfit.flatMap(Double.init)
        let stopLoss = tpslOrderData?.stopLoss.flatMap(Double.init)

        let autoclose = autocloseFormatter.format(
            takeProfit: takeProfit,
            stopLoss: stopLoss,
            takeProfitCanceled: tpCanceled && takeProfit == nil,
            stopLossCanceled: slCanceled && stopLoss == nil
        )

        return ListItemModel(
            title: Localized.Perpetual.autoClose,
            subtitle: autoclose.subtitle,
            subtitleExtra: autoclose.subtitleExtra
        )
    }
}
