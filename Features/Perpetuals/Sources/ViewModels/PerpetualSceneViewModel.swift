// Copyright (c). Gem Wallet. All rights reserved.

import Components
import Foundation
import InfoSheet
import Localization
import PerpetualService
import Primitives
import PrimitivesComponents
import Store
import SwiftUI
import Formatters
import ExplorerService
import Preferences
import BigInt

@Observable
@MainActor
public final class PerpetualSceneViewModel {
    private let perpetualService: PerpetualServiceable
    private let onTransferData: TransferDataAction
    private let onPerpetualRecipientData: ((PerpetualRecipientData) -> Void)?
    private let perpetualOrderFactory = PerpetualOrderFactory()

    public let wallet: Wallet
    public let asset: Asset

    public let explorerService: any ExplorerLinkFetchable = ExplorerService.standard

    public var positionsRequest: PerpetualPositionsRequest
    public var perpetualRequest: PerpetualRequest
    public var perpetualTotalValueRequest: TotalValueRequest
    public var transactionsRequest: TransactionsRequest

    public var positions: [PerpetualPositionData] = []
    public var perpetualData: PerpetualData = .empty
    public var perpetualTotalValue: Double = .zero
    public var transactions: [TransactionExtended] = []

    public var state: StateViewType<[ChartCandleStick]> = .loading
    public var currentPeriod: ChartPeriod = .day {
        didSet {
            Task {
                await fetchCandlesticks()
            }
        }
    }

    public var isPresentingInfoSheet: InfoSheetType?
    public var isPresentingModifyAlert: Bool?
    public var isPresentingAutoclose: Bool = false

    let preference = Preferences.standard

    public init(
        wallet: Wallet,
        asset: Asset,
        perpetualService: PerpetualServiceable,
        onTransferData: TransferDataAction = nil,
        onPerpetualRecipientData: ((PerpetualRecipientData) -> Void)? = nil
    ) {
        self.wallet = wallet
        self.asset = asset
        self.perpetualService = perpetualService
        self.onTransferData = onTransferData
        self.onPerpetualRecipientData = onPerpetualRecipientData

        self.positionsRequest = PerpetualPositionsRequest(walletId: wallet.id, filter: .assetId(asset.id))
        self.perpetualRequest = PerpetualRequest(assetId: asset.id)
        self.perpetualTotalValueRequest = TotalValueRequest(walletId: wallet.id, balanceType: .perpetual)

        let transactionTypes: [TransactionType] = [.perpetualOpenPosition, .perpetualClosePosition]
        self.transactionsRequest = TransactionsRequest(
            walletId: wallet.id,
            type: .asset(assetId: asset.id),
            filters: [.types(transactionTypes.map { $0.rawValue })]
        )
    }

    public var navigationTitle: String { perpetualViewModel.name }
    public var currency: String { preference.currency }
    public var hasOpenPosition: Bool { !positionViewModels.isEmpty }

    public var positionSectionTitle: String { Localized.Perpetual.position }
    public var infoSectionTitle: String { Localized.Common.info }
    public var transactionsSectionTitle: String { Localized.Activity.title }
    public var closePositionTitle: String { Localized.Perpetual.closePosition }
    public var modifyPositionTitle: String { Localized.Perpetual.modify }
    public var increasePositionTitle: String { Localized.Perpetual.increasePosition }
    public var reducePositionTitle: String { Localized.Perpetual.reducePosition }
    public var longButtonTitle: String { Localized.Perpetual.long }
    public var shortButtonTitle: String { Localized.Perpetual.short }

    public var perpetual: Perpetual { perpetualData.perpetual }
    public var perpetualViewModel: PerpetualViewModel { PerpetualViewModel(perpetual: perpetual) }
    public var positionViewModels: [PerpetualPositionViewModel] { positions.map { PerpetualPositionViewModel($0) } }

    var chartLineModels: [ChartLineViewModel] {
        guard let position = positions.first?.position else { return [] }
        let prices: [(ChartLineType, Double?)] = [
            (.entry, position.entryPrice),
            (.takeProfit, position.takeProfit?.price),
            (.stopLoss, position.stopLoss?.price),
            (.liquidation, position.liquidationPrice)
        ]
        return prices.compactMap { type, price in
            price.map { ChartLineViewModel(line: ChartLine(type: type, price: $0)) }
        }
    }

    public func fetch() async {
        Task {
            await fetchCandlesticks()
        }
        Task {
            try await perpetualService.updateMarket(symbol: perpetual.name)
        }
        Task {
            do {
                try await perpetualService.updatePositions(wallet: wallet)
            } catch {
                debugLog("Failed to load data: \(error)")
            }
        }
    }

    public func fetchCandlesticks() async {
        state = .loading

        do {
            let candlesticks = try await perpetualService.candlesticks(
                symbol: perpetual.name,
                period: currentPeriod
            )
            state = .data(candlesticks)
        } catch {
            state = .error(error)
        }
    }
}

// MARK: - Actions

public extension PerpetualSceneViewModel {
    func onSelectFundingRateInfo() {
        isPresentingInfoSheet = .fundingRate
    }

    func onSelectFundingPaymentsInfo() {
        isPresentingInfoSheet = .fundingPayments
    }

    func onSelectLiquidationPriceInfo() {
        isPresentingInfoSheet = .liquidationPrice
    }

    func onSelectOpenInterestInfo() {
        isPresentingInfoSheet = .openInterest
    }

    func onSelectAutoclose() {
        isPresentingAutoclose = true
    }

    func onSelectAutocloseInfo() {
        isPresentingInfoSheet = .autoclose
    }

    func onModifyPosition() {
        isPresentingModifyAlert = true
    }

    func onClosePosition() {
        guard
            let position = positions.first?.position,
            let assetIndex = UInt32(perpetual.identifier)
        else { return }

        let data = perpetualOrderFactory.makeCloseOrder(
            assetIndex: Int32(assetIndex),
            perpetual: perpetual,
            position: position,
            asset: asset,
            baseAsset: .hypercoreUSDC()
        )

        let transferData = TransferData(
            type: .perpetual(asset, .close(data)),
            recipientData: .hyperliquid(),
            value: .zero,
            canChangeValue: false
        )

        onTransferData?(transferData)
    }

    func onOpenLongPosition() {
        guard let transferData = createTransferData(
            direction: .long,
            leverage: perpetual.maxLeverage
        ) else {
            return
        }
        onPositionAction(.open(transferData))
    }

    func onOpenShortPosition() {
        guard let transferData = createTransferData(
            direction: .short,
            leverage: perpetual.maxLeverage
        ) else {
            return
        }
        onPositionAction(.open(transferData))
    }

    func onIncreasePosition() {
        isPresentingModifyAlert = false

        guard let position = positions.first?.position,
              let transferData = createTransferData(direction: position.direction, leverage: position.leverage)
        else { return }

        onPositionAction(.increase(transferData))
    }

    func onReducePosition() {
        isPresentingModifyAlert = false

        guard let position = positions.first?.position else {
            return
        }

        let direction: PerpetualDirection = {
            switch position.direction {
            case .long: .short
            case .short: .long
            }
        }()

        guard let transferData = createTransferData(direction: direction, leverage: position.leverage) else {
            return
        }

        onPositionAction(
            .reduce(
                transferData,
                available: BigInt(position.marginAmount * pow(10.0, Double(position.baseAsset.decimals))),
                positionDirection: position.direction
            )
        )
    }

    private func createTransferData(direction: PerpetualDirection, leverage: UInt8) -> PerpetualTransferData? {
        guard let assetIndex = Int(perpetual.identifier) else {
            return nil
        }

        return PerpetualTransferData(
            provider: perpetual.provider,
            direction: direction,
            asset: asset,
            baseAsset: .hypercoreUSDC(),
            assetIndex: assetIndex,
            price: perpetual.price,
            leverage: leverage
        )
    }

    private func onPositionAction(_ positionAction: PerpetualPositionAction) {
        let recipientData = PerpetualRecipientData(
            recipient: .hyperliquid(),
            positionAction: positionAction
        )
        onPerpetualRecipientData?(recipientData)
    }

    func onAutocloseComplete() {
        isPresentingAutoclose = false
        Task {
            await fetch()
        }
    }
}

extension RecipientData {
    static func hyperliquid() -> RecipientData {
        RecipientData(
            recipient: Recipient(name: "Hyperliquid", address: "", memo: .none),
            amount: .none
        )
    }
}
