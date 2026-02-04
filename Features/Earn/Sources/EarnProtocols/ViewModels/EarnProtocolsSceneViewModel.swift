// Copyright (c). Gem Wallet. All rights reserved.

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
    private let earnPositionsService: any EarnBalanceServiceable
    private let earnService: any EarnServiceType
    private let onAmountInputAction: AmountInputAction

    public var positionsRequest: EarnPositionsRequest
    public var positions: [EarnPosition] = []
    public var protocols: [EarnProtocolViewModel] = []

    public var protocolsState: StateViewType<Bool> = .loading

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
            chainPlaceholder: Images.EarnProviders.yo
        )
    }

    public var isLoading: Bool {
        protocolsState.isLoading
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
        earnPositionsService: any EarnBalanceServiceable,
        earnService: any EarnServiceType,
        onAmountInputAction: AmountInputAction = nil
    ) {
        self.wallet = wallet
        self.asset = asset
        self.earnPositionsService = earnPositionsService
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
            let protocols = try await earnService.getProtocols(for: asset.id)
            let protocolModels = protocols.map { EarnProtocolViewModel(protocol: $0) }
            self.protocols = protocolModels
            protocolsState = protocolModels.isEmpty ? .noData : .data(true)
        } catch {
            protocolsState = .error(error)
        }
    }

    private func updatePositions() async {
        guard !walletAddress.isEmpty else { return }
        await earnPositionsService.updatePositions(
            walletId: wallet.walletId,
            assetId: asset.id,
            address: walletAddress
        )
    }

    public func onSelectProtocol(_ opportunity: EarnProtocolViewModel) {
        let earnData = makeEarnData(provider: opportunity.provider.rawValue)
        let amountInput = AmountInput(
            type: .earn(action: .deposit, data: earnData, depositedBalance: nil),
            asset: asset
        )
        onAmountInputAction?(amountInput)
    }

    public func onWithdraw(_ position: EarnPositionViewModel) {
        let earnData = makeEarnData(provider: position.provider)
        let amountInput = AmountInput(
            type: .earn(action: .withdraw, data: earnData, depositedBalance: position.vaultBalance),
            asset: asset
        )
        onAmountInputAction?(amountInput)
    }

    private func makeEarnData(provider: String) -> EarnData {
        EarnData(
            provider: provider,
            contractAddress: nil,
            callData: nil,
            approval: nil,
            gasLimit: nil
        )
    }
}
