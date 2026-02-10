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
public final class EarnProvidersSceneViewModel {
    public let wallet: Wallet
    public let asset: Asset
    private let earnPositionsService: any EarnBalanceServiceable
    private let earnProviderService: EarnProviderService
    private let onAmountInputAction: AmountInputAction

    public var positionsRequest: DelegationsRequest
    public var positions: [Delegation] = []
    public var providers: [EarnProviderViewModel] = []

    public var providersState: StateViewType<Bool> = .loading

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
        providersState.isLoading
    }

    public var positionModels: [EarnPositionViewModel] {
        positions
            .compactMap { EarnPositionViewModel(delegation: $0, decimals: Int(asset.decimals)) }
            .filter { $0.hasBalance }
    }

    public var hasPosition: Bool {
        positionModels.isNotEmpty
    }

    public var hasProviders: Bool {
        !providers.isEmpty
    }

    public var hasError: Bool {
        providersState.isError
    }

    public var isEmpty: Bool {
        providersState.isNoData
    }

    public var error: Error? {
        if case .error(let error) = providersState {
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
        earnProviderService: EarnProviderService,
        onAmountInputAction: AmountInputAction = nil
    ) {
        self.wallet = wallet
        self.asset = asset
        self.earnPositionsService = earnPositionsService
        self.earnProviderService = earnProviderService
        self.onAmountInputAction = onAmountInputAction
        self.positionsRequest = DelegationsRequest(
            walletId: wallet.walletId,
            assetId: asset.id,
            providerType: .earn
        )
    }

    public func fetchOnce() {
        Task {
            await fetch()
        }
    }

    public func fetch() async {
        providersState = .loading
        async let _ = updatePositions()

        do {
            let earnProviders = try await earnProviderService.getProviders(for: asset.id)
            let providerModels = earnProviders.map { EarnProviderViewModel(provider: $0) }
            self.providers = providerModels
            providersState = providerModels.isEmpty ? .noData : .data(true)
        } catch {
            providersState = .error(error)
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

    public func onSelectProvider(_ provider: EarnProviderViewModel) {
        let amountInput = AmountInput(
            type: .earn(.deposit(provider: provider.earnProvider)),
            asset: asset
        )
        onAmountInputAction?(amountInput)
    }

    public func onWithdraw(_ position: EarnPositionViewModel) {
        let amountInput = AmountInput(
            type: .earn(.withdraw(delegation: position.delegation)),
            asset: asset
        )
        onAmountInputAction?(amountInput)
    }
}
