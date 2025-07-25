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
    private let onPresentTransferData: ((TransferData) -> Void)?
    
    public let wallet: Wallet
    public var perpetualData: PerpetualData
    public var positionsRequest: PerpetualPositionsRequest
    public var positions: [PerpetualPositionData] = [] {
        didSet {
            if let data = positions.first {
                self.perpetualData = PerpetualData(perpetual: data.perpetual, asset: data.asset)
            }
        }
    }
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
    
    public var positionViewModels: [PerpetualPositionItemViewModel] {
        positions.flatMap { positionData in
            positionData.positions.map { position in
                PerpetualPositionItemViewModel(
                    position: position,
                    perpetual: positionData.perpetual,
                    asset: positionData.asset
                )
            }
        }
    }
    
    public init(
        wallet: Wallet,
        perpetualData: PerpetualData,
        perpetualService: PerpetualServiceable,
        onPresentTransferData: ((TransferData) -> Void)? = nil
    ) {
        self.wallet = wallet
        self.perpetualData = perpetualData
        self.perpetualService = perpetualService
        self.onPresentTransferData = onPresentTransferData
        self.positionsRequest = PerpetualPositionsRequest(walletId: wallet.id, perpetualId: perpetualData.perpetual.id)
        self.perpetualViewModel = PerpetualViewModel(perpetual: perpetualData.perpetual)
    }
    
    public var navigationTitle: String {
        perpetualViewModel.name
    }
    
    public var hasOpenPosition: Bool {
        !positionViewModels.isEmpty
    }
    
    
    public func fetch() async {
        do {
            try await perpetualService.updateMarket(symbol: perpetualData.perpetual.name)
            try await perpetualService.updatePositions(wallet: wallet)
            await fetchCandlesticks()
        } catch {
            print("Failed to load data: \(error)")
        }
    }
    
    public func fetchCandlesticks() async {
        state = .loading
        
        do {
            let candlesticks = try await perpetualService.candlesticks(
                symbol: perpetualData.perpetual.name,
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
            type: .perpetual(perpetualData.asset, .close),
            recipientData: RecipientData(
                recipient: Recipient(name: "Hyperliquid", address: "0x", memo: .none),
                amount: .none
            ),
            value: .zero,
            canChangeValue: false,
            ignoreValueCheck: true
        )
        
        onPresentTransferData?(transferData)
    }
    
    public func onOpenLongPosition() {
        let transferData = TransferData(
            type: .perpetual(perpetualData.asset, .open(.long)),
            recipientData: RecipientData(
                recipient: Recipient(name: "Hyperliquid", address: "0x", memo: .none),
                amount: .none
            ),
            value: .zero,
            canChangeValue: true,
            ignoreValueCheck: false
        )
        
        onPresentTransferData?(transferData)
    }
    
    public func onOpenShortPosition() {
        let transferData = TransferData(
            type: .perpetual(perpetualData.asset, .open(.short)),
            recipientData: RecipientData(
                recipient: Recipient(name: "Hyperliquid", address: "0x", memo: .none),
                amount: .none
            ),
            value: .zero,
            canChangeValue: true,
            ignoreValueCheck: false
        )
        
        onPresentTransferData?(transferData)
    }
}
