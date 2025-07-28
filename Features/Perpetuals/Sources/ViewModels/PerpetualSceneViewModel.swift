// Copyright (c). Gem Wallet. All rights reserved.

import Components
import Formatters
import Foundation
import InfoSheet
import Localization
import PerpetualService
import Primitives
import PrimitivesComponents
import Store
import SwiftUI

@Observable
@MainActor
public final class PerpetualSceneViewModel {
    private let perpetualService: PerpetualServiceable
    private let onTransferData: TransferDataAction
    private let onPerpetualRecipientData: ((PerpetualRecipientData) -> Void)?

    public let wallet: Wallet
    public let asset: Asset
    public var positionsRequest: PerpetualPositionsRequest
    public var positions: [PerpetualPositionData] = []
    public var state: StateViewType<[ChartCandleStick]> = .loading
    public var currentPeriod: ChartPeriod = .hour {
        didSet {
            Task {
                await fetchCandlesticks()
            }
        }
    }

    public var isPresentingInfoSheet: InfoSheetType?

    public let perpetualViewModel: PerpetualViewModel

    public var positionViewModels: [PerpetualPositionViewModel] {
        positions.map { PerpetualPositionViewModel(data: $0) }
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
    }

    public var navigationTitle: String {
        perpetualViewModel.name
    }

    public var hasOpenPosition: Bool {
        !positionViewModels.isEmpty
    }

    public var positionSectionTitle: String { Localized.Perpetual.position }
    public var infoSectionTitle: String { Localized.Common.info }
    public var closePositionTitle: String { Localized.Perpetual.closePosition }
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

    func onClosePosition() {
        let hyperliquidAsset: UInt32 = 0 // FIXME: perpetualViewModel.perpetual.assetId.hyperliquidAssetId
        let price = perpetualViewModel.perpetual.price // Current Market price
        let size = "0" // FIXME: perpetualViewModel.perpetualPostion.size, need to know the size when close
        let transferData = TransferData(
            type: .perpetual(asset, .close(asset: hyperliquidAsset, price: price.description, size: size)),
            recipientData: .hyperliquid(),
            value: .zero,
            canChangeValue: false,
            ignoreValueCheck: true
        )

        onTransferData?(transferData)
    }

    func onOpenLongPosition() {
        onPerpetualRecipientData?(PerpetualRecipientData(
            recipientData: .hyperliquid(),
            direction: .long,
            asset: asset
        ))
    }

    func onOpenShortPosition() {
        onPerpetualRecipientData?(PerpetualRecipientData(
            recipientData: .hyperliquid(),
            direction: .short,
            asset: asset
        ))
    }
}

private extension RecipientData {
    static func hyperliquid() -> RecipientData {
        RecipientData(
            recipient: Recipient(name: "Hyperliquid", address: "", memo: .none),
            amount: .none
        )
    }
}
