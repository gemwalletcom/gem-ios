// Copyright (c). Gem Wallet. All rights reserved.

import Components
import ExplorerService
import Foundation
import InfoSheet
import Preferences
import Primitives
import PrimitivesComponents
import Store
import SwapService
import SwiftUI

@Observable
@MainActor
public final class TransactionSceneViewModel {
    private let preferences: Preferences
    private let explorerService: ExplorerService
    private let swapTransactionService: any SwapStatusProviding

    var request: TransactionRequest
    var transactionExtended: TransactionExtended
    var swapResult: SwapResult?

    var isPresentingShareSheet = false
    var isPresentingInfoSheet: InfoSheetType? = .none
    private var swapStatusTask: Task<Void, Never>?

    public init(
        transaction: TransactionExtended,
        walletId: String,
        preferences: Preferences = Preferences.standard,
        explorerService: ExplorerService = ExplorerService.standard,
        swapTransactionService: any SwapStatusProviding
    ) {
        self.preferences = preferences
        self.explorerService = explorerService
        self.swapTransactionService = swapTransactionService
        self.transactionExtended = transaction
        self.request = TransactionRequest(walletId: walletId, transactionId: transaction.id)
        startSwapStatusUpdates()
    }

    var title: String { model.titleTextValue.text }
    var explorerURL: URL { explorerViewModel.url }
}

// MAKR: - ListSectionProvideable

extension TransactionSceneViewModel: ListSectionProvideable {
    public var sections: [ListSection<TransactionItem>] {
        [
            ListSection(type: .header, [.header]),
            ListSection(type: .swapAction, [.swapButton]),
            ListSection(type: .details, detailItems),
            ListSection(type: .explorer, [.explorerLink])
        ]
    }

    public func itemModel(for item: TransactionItem) -> any ItemModelProvidable<TransactionItemModel> {
        switch item {
        case .header: headerViewModel
        case .swapButton: TransactionSwapButtonViewModel(transaction: transactionExtended)
        case .date: TransactionDateViewModel(date: model.transaction.transaction.createdAt)
        case .status:
            TransactionStatusViewModel(state: model.transaction.transaction.state, onInfoAction: onSelectStatusInfo)
        case .swapStatus:
            TransactionStatusViewModel(title: model.swapStatusTitle, state: model.transaction.transaction.state, swapResult: swapResult, onInfoAction: onSelectStatusInfo)
        case .participant: TransactionParticipantViewModel(transactionViewModel: model)
        case .memo: TransactionMemoViewModel(transaction: model.transaction.transaction)
        case .network: TransactionNetworkViewModel(chain: model.transaction.asset.chain)
        case .pnl: TransactionPnlViewModel(metadata: model.transaction.transaction.metadata)
        case .price: TransactionPriceViewModel(metadata: model.transaction.transaction.metadata)
        case .size: TransactionSizeViewModel(transaction: model.transaction)
        case .provider: TransactionProviderViewModel(transaction: model.transaction.transaction)
        case .fee: TransactionNetworkFeeViewModel(feeDisplay: model.infoModel.feeDisplay, onInfoAction: onSelectFee)
        case .explorerLink: TransactionExplorerViewModel(transactionViewModel: model, explorerService: explorerService)
        }
    }
}

// MARK: - Actions

extension TransactionSceneViewModel {
    func onChangeTransaction(_ oldValue: TransactionExtended, _ newValue: TransactionExtended) {
        if oldValue != newValue {
            transactionExtended = newValue
            restartSwapStatusUpdates()
        }
    }

    func onSelectTransactionHeader() {
        if let headerLink = headerViewModel.headerLink {
            UIApplication.shared.open(headerLink)
        }
    }

    func onSelectShare() {
        isPresentingShareSheet = true
    }

    private func onSelectFee() {
        let chain = model.transaction.transaction.assetId.chain
        isPresentingInfoSheet = .networkFee(chain)
    }

    private func onSelectStatusInfo() {
        let assetImage = model.assetImage
        isPresentingInfoSheet = .transactionState(
            imageURL: assetImage.imageURL,
            placeholder: assetImage.placeholder,
            state: model.transaction.transaction.state
        )
    }
}

// MARK: - Private

extension TransactionSceneViewModel {
    private var model: TransactionViewModel {
        TransactionViewModel(
            explorerService: ExplorerService.standard,
            transaction: transactionExtended,
            currency: preferences.currency
        )
    }

    private var headerViewModel: TransactionHeaderViewModel {
        TransactionHeaderViewModel(
            transaction: model.transaction,
            infoModel: model.infoModel
        )
    }

    private var explorerViewModel: TransactionExplorerViewModel {
        TransactionExplorerViewModel(
            transactionViewModel: model,
            explorerService: explorerService
        )
    }

    private var detailItems: [TransactionItem] {
        var items: [TransactionItem] = [.date]
        if isCrossChainSwap {
            items.append(.swapStatus)
        }

        if !isCrossChainSwap {
            items.append(.status)
        }

        items.append(contentsOf: [.participant, .memo, .network, .pnl, .price, .size, .provider, .fee])
        return items
    }

    private var swapMetadata: TransactionSwapMetadata? {
        guard case let .swap(metadata) = transactionExtended.transaction.metadata else { return nil }
        return metadata
    }

    private var isCrossChainSwap: Bool {
        guard let metadata = swapMetadata else { return false }
        return metadata.fromAsset.chain != metadata.toAsset.chain
    }

    private var swapProviderIdentifier: String? {
        swapMetadata?.provider
    }

    private func restartSwapStatusUpdates() {
        swapStatusTask?.cancel()
        swapStatusTask = nil
        swapResult = nil
        startSwapStatusUpdates()
    }

    private func startSwapStatusUpdates() {
        guard swapStatusTask == nil else { return }
        guard isCrossChainSwap, let provider = swapProviderIdentifier else { return }

        let chain = transactionExtended.transaction.assetId.chain
        let transactionId = transactionExtended.transaction.hash
        // Stellar might be different here
        let memo = transactionExtended.transaction.memo ?? transactionExtended.transaction.to

        swapStatusTask = Task { [weak self] in
            await self?.pollSwapStatus(provider: provider, chain: chain, transactionId: transactionId, memo: memo)
        }
    }

    private func pollSwapStatus(provider: String, chain: Chain, transactionId: String, memo: String?) async {
        defer { swapStatusTask = nil }

        var backoff: Duration = .seconds(5)

        while !Task.isCancelled {
            do {
                let result = try await swapTransactionService.getSwapResult(
                    providerId: provider,
                    chain: chain,
                    transactionId: transactionId,
                    memo: memo
                )
                swapResult = result
                if result.status != .pending { break }
                backoff = .seconds(5)
            } catch {
                NSLog("TransactionSceneViewModel swap status error: \(error)")
                try? await Task.sleep(for: backoff)
                backoff = min(backoff * 2, .seconds(300))
                continue
            }

            try? await Task.sleep(for: .seconds(30))
        }
    }
}
