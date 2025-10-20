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

@Observable
@MainActor
public final class PerpetualSceneViewModel {
    private let perpetualService: PerpetualServiceable
    private let onTransferData: TransferDataAction
    private let onPerpetualRecipientData: ((PerpetualRecipientData) -> Void)?

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
    let formatter = PerpetualPriceFormatter()
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
                print("Failed to load data: \(error)")
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
            let assetIndex = UInt32(perpetualViewModel.perpetual.identifier) else {
            return
        }
        // Add 2% slippage for market-like execution
        // For closing long: sell 2% below market
        // For closing short: buy 2% above market
        let positionPrice = switch position.direction {
        case .long: perpetualViewModel.perpetual.price * 0.98
        case .short: perpetualViewModel.perpetual.price * 1.02
        }
        
        let price = formatter.formatPrice(provider: perpetualViewModel.perpetual.provider, positionPrice, decimals: Int(asset.decimals))
        let size = formatter.formatSize(provider: perpetualViewModel.perpetual.provider, abs(position.size), decimals: Int(asset.decimals))
        let data = PerpetualConfirmData(
            direction: position.direction,
            baseAsset: .hyperliquidUSDC(),
            assetIndex: Int32(assetIndex),
            price: price,
            fiatValue: abs(position.size) * positionPrice,
            size: size
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
        guard let assetIndex = UInt32(perpetualViewModel.perpetual.identifier) else {
            return
        }
        let data = PerpetualRecipientData(
            recipient: .hyperliquid(),
            data: PerpetualTransferData(
                provider: perpetualViewModel.perpetual.provider,
                direction: .long,
                asset: asset,
                baseAsset: .hyperliquidUSDC(),
                assetIndex: Int(assetIndex),
                price: perpetualViewModel.perpetual.price,
                leverage: Int(perpetualViewModel.perpetual.leverage.last ?? 3)
            )
        )
        onPerpetualRecipientData?(data)
    }

    func onOpenShortPosition() {
        guard let assetIndex = UInt32(perpetualViewModel.perpetual.identifier) else {
            return
        }
        let data = PerpetualRecipientData(
            recipient: .hyperliquid(),
            data: PerpetualTransferData(
                provider: perpetualViewModel.perpetual.provider,
                direction: .short,
                asset: asset,
                baseAsset: .hyperliquidUSDC(),
                assetIndex: Int(assetIndex),
                price: perpetualViewModel.perpetual.price,
                leverage: Int(perpetualViewModel.perpetual.leverage.last ?? 3)
            )
        )
        onPerpetualRecipientData?(data)
    }

    func onIncreasePosition() {
        isPresentingModifyAlert = false

        guard let direction = positions.first?.position.direction else {
            return
        }

        switch direction {
        case .long:
            onOpenLongPosition()
        case .short:
            onOpenShortPosition()
        }
    }

    func onReducePosition() {
        isPresentingModifyAlert = false

        guard let direction = positions.first?.position.direction else {
            return
        }

        switch direction {
        case .long:
            onOpenShortPosition()
        case .short:
            onOpenLongPosition()
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
