// Copyright (c). Gem Wallet. All rights reserved.

import BalanceService
import Components
import Foundation
import Localization
import Primitives
import Store
import Style
import EarnService

@MainActor
@Observable
public final class EarnProtocolsSceneViewModel {
    public let wallet: Wallet
    public let asset: Asset
    private let balanceService: BalanceService
    private let earnService: any EarnServiceType
    private let onAmountInputAction: AmountInputAction

    public var positionsRequest: EarnPositionsRequest
    public var positions: [EarnPosition] = []

    private var protocolsState: StateViewType<[EarnProtocolViewModel]> = .loading

    public var title: String {
        Localized.Common.earn
    }

    public var assetName: String {
        asset.name
    }

    public var assetSymbol: String {
        asset.symbol
    }

    public var assetImage: AssetImage {
        AssetImage(
            type: asset.type.rawValue,
            imageURL: AssetImageFormatter.shared.getURL(for: asset.id),
            placeholder: nil,
            chainPlaceholder: Images.YieldProviders.yo
        )
    }

    public var isLoading: Bool {
        protocolsState.isLoading
    }

    public var protocols: [EarnProtocolViewModel] {
        protocolsState.value ?? []
    }

    public var positionModels: [EarnPositionViewModel] {
        positions
            .compactMap { EarnPositionViewModel(position: $0, decimals: Int(asset.decimals)) }
            .filter { $0.hasBalance }
    }

    public var hasPosition: Bool {
        positionModels.isNotEmpty
    }

    public var hasProtocols: Bool {
        !protocols.isEmpty
    }

    public var hasError: Bool {
        protocolsState.isError
    }

    public var isEmpty: Bool {
        protocolsState.isNoData
    }

    public var error: Error? {
        if case .error(let error) = protocolsState {
            return error
        }
        return nil
    }

    public var emptyStateTitle: String {
        Localized.Errors.noDataAvailable
    }

    public var walletAddress: String {
        (try? wallet.account(for: asset.id.chain))?.address ?? ""
    }

    public init(
        wallet: Wallet,
        asset: Asset,
        balanceService: BalanceService,
        earnService: any EarnServiceType,
        onAmountInputAction: AmountInputAction = nil
    ) {
        self.wallet = wallet
        self.asset = asset
        self.balanceService = balanceService
        self.earnService = earnService
        self.onAmountInputAction = onAmountInputAction
        self.positionsRequest = EarnPositionsRequest(
            walletId: wallet.walletId,
            assetId: asset.id
        )
    }

    public func fetchOnce() {
        Task {
            await fetch()
        }
    }

    public func fetch() async {
        protocolsState = .loading
        async let _ = updatePositions()

        do {
            let yields = try await earnService.getYields(for: asset.id)
            let protocols = yields.map { EarnProtocolViewModel(yield: $0) }
            protocolsState = protocols.isEmpty ? .noData : .data(protocols)
        } catch {
            protocolsState = .error(error)
        }
    }

    private func updatePositions() async {
        guard !walletAddress.isEmpty else { return }
        await balanceService.updateYieldPositions(
            walletId: wallet.walletId,
            assetId: asset.id,
            address: walletAddress
        )
    }

    public func onSelectProtocol(_ opportunity: EarnProtocolViewModel) {
        let earnData = EarnData(
            provider: opportunity.provider.name,
            contractAddress: nil,
            callData: nil,
            approval: nil,
            gasLimit: nil
        )
        let amountInput = AmountInput(
            type: .yield(action: .deposit, data: earnData, depositedBalance: nil),
            asset: asset
        )
        onAmountInputAction?(amountInput)
    }

    public func onWithdraw(_ position: EarnPositionViewModel) {
        let earnData = EarnData(
            provider: position.provider,
            contractAddress: nil,
            callData: nil,
            approval: nil,
            gasLimit: nil
        )
        let amountInput = AmountInput(
            type: .yield(action: .withdraw, data: earnData, depositedBalance: position.vaultBalance),
            asset: asset
        )
        onAmountInputAction?(amountInput)
    }
}
