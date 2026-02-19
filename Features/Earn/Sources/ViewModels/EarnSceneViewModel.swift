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
import PrimitivesComponents

@MainActor
@Observable
public final class EarnSceneViewModel {
    private let earnService: EarnService
    private var viewState: StateViewType<Bool> = .loading

    public let wallet: Wallet
    public let asset: Asset
    private let currencyCode: String

    public var assetRequest: AssetRequest
    public var assetData: AssetData = .empty

    public var positionsRequest: DelegationsRequest
    public var positions: [Delegation] = []
    public var providersRequest: ValidatorsRequest
    public var providers: [DelegationValidator] = []

    public init(
        wallet: Wallet,
        asset: Asset,
        currencyCode: String,
        earnService: EarnService
    ) {
        self.wallet = wallet
        self.asset = asset
        self.currencyCode = currencyCode
        self.earnService = earnService
        self.assetRequest = AssetRequest(walletId: wallet.walletId, assetId: asset.id)
        self.positionsRequest = DelegationsRequest(
            walletId: wallet.walletId,
            assetId: asset.id,
            providerType: .earn
        )
        self.providersRequest = ValidatorsRequest(chain: asset.id.chain, providerType: .earn)
    }

    var title: String { Localized.Common.earn }
    var assetTitle: String { "\(asset.symbol) (\(asset.chain.asset.name))" }

    var aprTitle: String { Localized.Stake.apr("") }
    var aprValue: String {
        let apr = providers.first.map(\.apr).flatMap { $0 > 0 ? $0 : nil }
            ?? assetData.metadata.earnApr
        guard let apr, apr > 0 else { return "-" }
        return CurrencyFormatter.percentSignLess.string(apr)
    }

    var showDeposit: Bool {
        wallet.canSign && providers.isNotEmpty
    }

    var depositDestination: AmountInput {
        AmountInput(
            type: .earn(.deposit(providers.first!)),
            asset: asset
        )
    }

    var emptyContentModel: EmptyContentTypeViewModel {
        EmptyContentTypeViewModel(type: .earn(symbol: asset.symbol))
    }

    var positionModels: [DelegationViewModel] {
        positions
            .filter { (BigInt($0.base.balance) ?? .zero) > 0 }
            .map { DelegationViewModel(delegation: $0, asset: asset, currencyCode: currencyCode) }
    }

    var hasPositions: Bool {
        positionModels.isNotEmpty
    }

    var showEmptyState: Bool {
        !hasPositions && !viewState.isLoading
    }

    var positionsSectionTitle: String {
        hasPositions ? Localized.Perpetual.positions : .empty
    }

    var providersState: StateViewType<Bool> {
        switch viewState {
        case .noData: .noData
        case .loading: providers.isEmpty ? .loading : .data(true)
        case .data: providers.isEmpty ? .noData : .data(true)
        case .error(let error): .error(error)
        }
    }
}

// MARK: - Actions

extension EarnSceneViewModel {
    func fetch() async {
        viewState = .loading
        do {
            let address = (try? wallet.account(for: asset.id.chain))?.address ?? ""
            try await earnService.update(
                walletId: wallet.walletId,
                assetId: asset.id,
                address: address
            )
            viewState = .data(true)
        } catch {
            viewState = .error(error)
        }
    }
}
