// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Store
import PerpetualService
import PrimitivesComponents
import Formatters
import Components
import Localization
import InfoSheet

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
        guard let positionData = positions.first else {
            return []
        }
        return [
            PerpetualPositionViewModel(data: positionData)
        ]
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

extension PerpetualSceneViewModel {
    public func onSelectFundingRateInfo() {
        isPresentingInfoSheet = .fundingRate
    }
    
    public func onSelectFundingPaymentsInfo() {
        isPresentingInfoSheet = .fundingPayments
    }
    
    public func onSelectLiquidationPriceInfo() {
        isPresentingInfoSheet = .liquidationPrice
    }
    
    public func onSelectOpenInterestInfo() {
        isPresentingInfoSheet = .openInterest
    }
    
    public func onClosePosition() {
        let transferData = TransferData(
            type: .perpetual(asset, .close),
            recipientData: RecipientData(
                recipient: Recipient(name: "Hyperliquid", address: "0x", memo: .none),
                amount: .none
            ),
            value: .zero,
            canChangeValue: false,
            ignoreValueCheck: true
        )
        
        onTransferData?(transferData)
    }
    
    public func onOpenLongPosition() {
        let recipientData = RecipientData(
            recipient: Recipient(name: "Hyperliquid", address: "0x", memo: .none),
            amount: .none
        )
        
        onPerpetualRecipientData?(PerpetualRecipientData(
            recipientData: recipientData,
            direction: .long,
            asset: asset
        ))
    }
    
    public func onOpenShortPosition() {
        let recipientData = RecipientData(
            recipient: Recipient(name: "Hyperliquid", address: "0x", memo: .none),
            amount: .none
        )
        
        onPerpetualRecipientData?(PerpetualRecipientData(
            recipientData: recipientData,
            direction: .short,
            asset: asset
        ))
    }
}
