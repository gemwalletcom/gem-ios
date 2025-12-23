// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Formatters
import Foundation
import GemstonePrimitives
import Localization
import Perpetuals
import PerpetualService
import Primitives
import PrimitivesComponents
import Validators

struct AmountPerpetualViewModel {
    private let type: AmountType
    private let selectedLeverage: LeverageOption
    private let takeProfit: Double?
    private let stopLoss: Double?
    private let autocloseFormatter: AutocloseFormatter
    private let perpetualFormatter: PerpetualFormatter

    init(
        type: AmountType,
        selectedLeverage: LeverageOption,
        takeProfit: Double?,
        stopLoss: Double?,
        autocloseFormatter: AutocloseFormatter = AutocloseFormatter(),
        perpetualFormatter: PerpetualFormatter = PerpetualFormatter(provider: .hypercore)
    ) {
        self.type = type
        self.selectedLeverage = selectedLeverage
        self.takeProfit = takeProfit
        self.stopLoss = stopLoss
        self.autocloseFormatter = autocloseFormatter
        self.perpetualFormatter = perpetualFormatter
    }

    var leverageViewModel: AmountLeverageViewModel {
        AmountLeverageViewModel(type: type, selectedLeverage: selectedLeverage)
    }

    var autocloseViewModel: AmountAutocloseViewModel {
        AmountAutocloseViewModel(
            type: type,
            takeProfit: takeProfit,
            stopLoss: stopLoss,
            formatter: autocloseFormatter
        )
    }

    var leverageTitle: String { Localized.Perpetual.leverage }
    var autocloseTitle: String { Localized.Perpetual.autoClose }

    var minimumOrderAmount: BigInt {
        guard case .perpetual(let data) = type else { return .zero }
        return BigInt(
            perpetualFormatter.minimumOrderUsdAmount(
                price: data.positionAction.transferData.price,
                decimals: data.positionAction.transferData.asset.decimals,
                leverage: selectedLeverage.value
            )
        )
    }

    func perpetualOrder(value: BigInt, assetDecimals: Int) throws -> PerpetualType {
        guard case .perpetual(let data) = type else {
            throw TransferError.invalidAmount
        }
        let decimals = data.positionAction.transferData.asset.decimals
        return PerpetualOrderFactory().makePerpetualOrder(
            positionAction: data.positionAction,
            usdcAmount: value,
            usdcDecimals: assetDecimals,
            leverage: selectedLeverage.value,
            takeProfit: takeProfit.map { perpetualFormatter.formatPrice($0, decimals: decimals) },
            stopLoss: stopLoss.map { perpetualFormatter.formatPrice($0, decimals: decimals) }
        )
    }
}
