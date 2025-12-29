// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import Formatters
import GemstonePrimitives
import Localization
import PerpetualService
import Perpetuals
import Preferences
import Primitives
import PrimitivesComponents
import Style

struct AmountPerpetualLimits {
    static let minDeposit = BigInt(5_000_000)
    static let minWithdraw = BigInt(2_000_000)
}

@Observable
final class AmountPerpetualViewModel: AmountDataProvidable {
    let asset: Asset
    let data: PerpetualRecipientData
    let leverageSelection: LeverageSelection?
    let currencyFormatter: CurrencyFormatter
    
    var takeProfit: String?
    var stopLoss: String?

    private var transferData: PerpetualTransferData { data.positionAction.transferData }
    private var leverage: UInt8 { leverageSelection?.selected.value ?? transferData.leverage }

    init(asset: Asset, data: PerpetualRecipientData, preferences: Preferences = .standard) {
        self.asset = asset
        self.data = data
        self.currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: preferences.currency)
        self.leverageSelection = Self.makeLeverageSelection(data: data, preferences: preferences)
    }

    var leverageTitle: String { Localized.Perpetual.leverage }
    var autocloseTitle: String { Localized.Perpetual.autoClose }

    var isAutocloseEnabled: Bool {
        switch data.positionAction {
        case .open: true
        case .increase, .reduce: false
        }
    }

    var autocloseText: (subtitle: String, subtitleExtra: String?) {
        AutocloseFormatter().format(
            takeProfit: takeProfit.flatMap { currencyFormatter.double(from: $0) },
            stopLoss: stopLoss.flatMap { currencyFormatter.double(from: $0) }
        )
    }

    var title: String {
        switch data.positionAction {
        case .open:
            PerpetualDirectionViewModel(direction: transferData.direction).title
        case .increase:
            PerpetualDirectionViewModel(direction: transferData.direction).increaseTitle
        case .reduce(_, _, let direction):
            PerpetualDirectionViewModel(direction: direction).reduceTitle
        }
    }

    var amountType: AmountType {
        .perpetual(data)
    }

    var minimumValue: BigInt {
        BigInt(
            PerpetualFormatter(provider: .hypercore).minimumOrderUsdAmount(
                price: transferData.price,
                decimals: transferData.asset.decimals,
                leverage: leverage
            )
        )
    }

    var canChangeValue: Bool { true }
    var reserveForFee: BigInt { .zero }

    func shouldReserveFee(from assetData: AssetData) -> Bool { false }

    func availableValue(from assetData: AssetData) -> BigInt {
        switch data.positionAction {
        case .open, .increase: assetData.balance.available
        case .reduce(_, let available, _): available
        }
    }

    func recipientData() -> RecipientData {
        data.recipient
    }

    func makeTransferData(value: BigInt) throws -> TransferData {
        let formatter = PerpetualFormatter(provider: .hypercore)

        let perpetualType = PerpetualOrderFactory().makePerpetualOrder(
            positionAction: data.positionAction,
            usdcAmount: value,
            usdcDecimals: asset.decimals.asInt,
            leverage: leverage,
            takeProfit: takeProfit
                .flatMap { currencyFormatter.double(from: $0) }
                .map { formatter.formatPrice($0, decimals: transferData.asset.decimals) },
            stopLoss: stopLoss
                .flatMap { currencyFormatter.double(from: $0) }
                .map { formatter.formatPrice($0, decimals: transferData.asset.decimals) }
        )

        return TransferData(
            type: .perpetual(transferData.asset, perpetualType),
            recipientData: data.recipient,
            value: value,
            canChangeValue: true
        )
    }

    func makeAutocloseData(size: Double) -> AutocloseOpenData {
        AutocloseOpenData(
            assetId: transferData.asset.id,
            symbol: transferData.asset.symbol,
            direction: transferData.direction,
            marketPrice: transferData.price,
            leverage: leverageSelection?.selected.value ?? 1,
            size: size,
            assetDecimals: transferData.asset.decimals,
            takeProfit: takeProfit,
            stopLoss: stopLoss
        )
    }

    private static func makeLeverageSelection(data: PerpetualRecipientData, preferences: Preferences) -> LeverageSelection? {
        guard case let .open(openData) = data.positionAction else { return nil }

        let transferData = data.positionAction.transferData
        let textStyle = TextStyle(
            font: .callout,
            color: PerpetualDirectionViewModel(direction: openData.direction).color
        )

        let initialLeverage = LeverageOption.option(
            desiredValue: preferences.perpetualLeverage,
            from: LeverageOption.allOptions.filter { $0.value <= transferData.leverage }
        )

        return LeverageSelection(
            maxLeverage: transferData.leverage,
            initial: initialLeverage,
            textStyle: textStyle
        )
    }
}
