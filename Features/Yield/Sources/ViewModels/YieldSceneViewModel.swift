// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Components
import Formatters
import Foundation
import Gemstone
import Primitives
import Style
import YieldService

public struct YieldPositionViewModel: Sendable {
    public let position: GemYieldPosition
    public let decimals: Int

    public init(position: GemYieldPosition, decimals: Int) {
        self.position = position
        self.decimals = decimals
    }

    public var hasBalance: Bool {
        vaultBalance.map { $0 > 0 } ?? false
    }

    public var vaultBalance: BigInt? {
        position.vaultBalanceValue.flatMap { BigInt($0) }
    }

    public var assetBalanceFormatted: String {
        guard let balance = position.assetBalanceValue.flatMap({ BigInt($0) }) else {
            return "0"
        }
        return ValueFormatter(style: .medium).string(balance, decimals: decimals)
    }

    public var rewardsFormatted: String? {
        guard let rewards = position.rewards.flatMap({ BigInt($0) }), rewards > 0 else {
            return nil
        }
        return ValueFormatter(style: .medium).string(rewards, decimals: decimals)
    }

    public var providerName: String {
        position.provider.displayName
    }
}

public enum YieldState: Sendable {
    case idle
    case loading
    case loaded([YieldOpportunityViewModel], YieldPositionViewModel?)
    case error(Error)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var opportunities: [YieldOpportunityViewModel] {
        if case .loaded(let yields, _) = self { return yields }
        return []
    }

    var position: YieldPositionViewModel? {
        if case .loaded(_, let position) = self { return position }
        return nil
    }

    var error: Error? {
        if case .error(let error) = self { return error }
        return nil
    }

    var hasError: Bool {
        error != nil
    }
}

public typealias AmountInputAction = ((AmountInput) -> Void)?

@MainActor
@Observable
public final class YieldSceneViewModel {
    private let input: YieldInput
    private let yieldService: YieldService
    private let onAmountInputAction: AmountInputAction

    public private(set) var state: YieldState = .idle

    public var title: String {
        "Earn"
    }

    public var assetName: String {
        input.asset.name
    }

    public var assetSymbol: String {
        input.asset.symbol
    }

    public var assetImage: AssetImage {
        AssetImage(
            type: input.asset.type.rawValue,
            imageURL: AssetImageFormatter.shared.getURL(for: input.asset.id),
            placeholder: nil,
            chainPlaceholder: Images.YieldProviders.yo
        )
    }

    public var isLoading: Bool {
        state.isLoading
    }

    public var opportunities: [YieldOpportunityViewModel] {
        state.opportunities
    }

    public var position: YieldPositionViewModel? {
        state.position
    }

    public var hasPosition: Bool {
        position?.hasBalance ?? false
    }

    public var hasOpportunities: Bool {
        !opportunities.isEmpty
    }

    public var hasError: Bool {
        state.hasError
    }

    public var errorMessage: String? {
        state.error?.localizedDescription
    }

    public var emptyStateTitle: String {
        "No yield opportunities available"
    }

    public var walletAddress: String {
        (try? input.wallet.account(for: input.asset.id.chain))?.address ?? ""
    }

    public var wallet: Wallet {
        input.wallet
    }

    public init(
        input: YieldInput,
        yieldService: YieldService,
        onAmountInputAction: AmountInputAction = nil
    ) {
        self.input = input
        self.yieldService = yieldService
        self.onAmountInputAction = onAmountInputAction
    }

    public func fetchOnce() {
        Task {
            await fetch()
        }
    }

    public func fetch() async {
        state = .loading

        let cached = yieldService.getPosition(
            provider: .yo,
            asset: input.asset.id,
            walletAddress: walletAddress,
            walletId: input.wallet.walletId
        ) { [weak self] fresh in
            self?.updateState(with: fresh)
        }

        if let cached {
            updateState(with: cached)
        }
    }

    private func updateState(with position: GemYieldPosition) {
        let positionViewModel = YieldPositionViewModel(
            position: position,
            decimals: Int(input.asset.decimals)
        )
        let opportunity = YieldOpportunityViewModel(position: position)
        state = .loaded([opportunity], positionViewModel)
    }

    public func onSelectOpportunity(_ opportunity: YieldOpportunityViewModel) {
        let yieldData = Primitives.YieldData(
            providerName: opportunity.provider.name,
            contractAddress: "",
            callData: "",
            approval: nil,
            gasLimit: nil
        )
        let amountInput = AmountInput(
            type: .yield(action: .deposit, data: yieldData, depositedBalance: nil),
            asset: input.asset
        )
        onAmountInputAction?(amountInput)
    }

    public func onWithdraw() {
        guard let position = position else { return }
        let yieldData = Primitives.YieldData(
            providerName: position.providerName,
            contractAddress: "",
            callData: "",
            approval: nil,
            gasLimit: nil
        )
        let amountInput = AmountInput(
            type: .yield(action: .withdraw, data: yieldData, depositedBalance: position.vaultBalance),
            asset: input.asset
        )
        onAmountInputAction?(amountInput)
    }
}
