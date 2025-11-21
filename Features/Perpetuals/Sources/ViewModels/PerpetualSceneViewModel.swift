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
    public var perpetualTotalValueRequest: TotalValueRequest
    public var transactionsRequest: TransactionsRequest
    public var positions: [PerpetualPositionData] = []
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
    let preference = Preferences.standard
    public var isPresentingInfoSheet: InfoSheetType?
    public var isPresentingModifyAlert: Bool?
    public var isPresentingAutoclose: Bool = false

    public let perpetualViewModel: PerpetualViewModel

    public var positionViewModels: [PerpetualPositionViewModel] {
        positions.map { PerpetualPositionViewModel($0) }
    }

    public init(
        wallet: Wallet,
        perpetualData: PerpetualData,
        perpetualService: PerpetualServiceable,
        onTransferData: TransferDataAction = nil,
        onPerpetualRecipientData: ((PerpetualRecipientData) -> Void)? = nil
    ) {
        self.wallet = wallet
        self.asset = perpetualData.asset
        self.perpetualService = perpetualService
        self.onTransferData = onTransferData
        self.onPerpetualRecipientData = onPerpetualRecipientData
        self.perpetualViewModel = PerpetualViewModel(perpetual: perpetualData.perpetual)
        self.positionsRequest = PerpetualPositionsRequest(walletId: wallet.id, perpetualId: perpetualData.perpetual.id)
        self.perpetualTotalValueRequest = TotalValueRequest(walletId: wallet.id, balanceType: .perpetual)
        
        self.transactionsRequest = TransactionsRequest(
            walletId: wallet.id,
            type: .asset(assetId: asset.id),
            filters: [.types([TransactionType.perpetualOpenPosition, TransactionType.perpetualClosePosition].map { $0.rawValue })]
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

    public func fetch() async {
        Task {
            await fetchCandlesticks()
        }
        Task {
            try await perpetualService.updateMarket(symbol: perpetualViewModel.perpetual.name)
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
                symbol: perpetualViewModel.perpetual.name,
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
            let assetIndex = UInt32(perpetualViewModel.perpetual.identifier)
        else { return }

        let data = perpetualOrderFactory.makeCloseOrder(
            assetIndex: Int32(assetIndex),
            perpetual: perpetualViewModel.perpetual,
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
        guard let transferData = createTransferData(direction: .long) else {
            return
        }
        onPositionAction(.open(transferData))
    }

    func onOpenShortPosition() {
        guard let transferData = createTransferData(direction: .short) else {
            return
        }
        onPositionAction(.open(transferData))
    }

    func onIncreasePosition() {
        isPresentingModifyAlert = false

        guard let direction = positions.first?.position.direction,
              let transferData = createTransferData(direction: direction)
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

        guard let transferData = createTransferData(direction: direction) else {
            return
        }

        onPositionAction(
            .reduce(
                transferData,
                available: BigInt(position.marginAmount * pow(10.0, Double(position.baseAsset.decimals))),
                positionDirection: position.direction,
                position: position
            )
        )
    }

    private func createTransferData(direction: PerpetualDirection) -> PerpetualTransferData? {
        guard let assetIndex = Int(perpetualViewModel.perpetual.identifier) else {
            return nil
        }

        return PerpetualTransferData(
            provider: perpetualViewModel.perpetual.provider,
            direction: direction,
            asset: asset,
            baseAsset: .hypercoreUSDC(),
            assetIndex: assetIndex,
            price: perpetualViewModel.perpetual.price,
            leverage: perpetualViewModel.perpetual.maxLeverage
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
