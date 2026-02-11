// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Components
import Foundation
import Formatters
import Localization
import Primitives
import Store
import Style
import EarnService
import Staking

@MainActor
@Observable
public final class EarnSceneViewModel {
    private let earnService: any EarnBalanceServiceable
    private var fetchState: StateViewType<Bool> = .loading

    public let wallet: Wallet
    public let asset: Asset

    public var positionsRequest: DelegationsRequest
    public var positions: [Delegation] = []
    public var providersRequest: EarnProvidersRequest
    public var providers: [DelegationValidator] = []

    public init(
        wallet: Wallet,
        asset: Asset,
        earnService: any EarnBalanceServiceable
    ) {
        self.wallet = wallet
        self.asset = asset
        self.earnService = earnService
        self.positionsRequest = DelegationsRequest(
            walletId: wallet.walletId,
            assetId: asset.id,
            providerType: .earn
        )
        self.providersRequest = EarnProvidersRequest(chain: asset.id.chain)
    }

    var title: String { Localized.Common.earn }
    var assetTitle: String { "\(asset.name) (\(asset.symbol))" }

    var aprTitle: String { Localized.Stake.apr("") }
    var aprValue: String {
        guard let provider = providers.first, provider.apr > 0 else {
            return "-"
        }
        return CurrencyFormatter.percentSignLess.string(provider.apr)
    }

    var showDeposit: Bool {
        wallet.canSign && providers.isNotEmpty
    }

    var depositDestination: AmountInput {
        AmountInput(
            type: .earn(.deposit(provider: providers.first!)),
            asset: asset
        )
    }

    var positionModels: [StakeDelegationViewModel] {
        positions
            .filter { (BigInt($0.base.balance) ?? .zero) > 0 }
            .map { StakeDelegationViewModel(delegation: $0, asset: asset) }
    }

    var hasPositions: Bool {
        positionModels.isNotEmpty
    }

    var providersState: StateViewType<Bool> {
        switch fetchState {
        case .noData: return .noData
        case .loading: return providers.isEmpty ? .loading : .data(true)
        case .data: return providers.isEmpty ? .noData : .data(true)
        case .error(let error): return .error(error)
        }
    }
}

// MARK: - Actions

extension EarnSceneViewModel {
    func fetch() async {
        fetchState = .loading
        do {
            let address = (try? wallet.account(for: asset.id.chain))?.address ?? ""
            try await earnService.update(
                walletId: wallet.walletId,
                assetId: asset.id,
                address: address
            )
            fetchState = .data(true)
        } catch {
            fetchState = .error(error)
        }
    }
}
