// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Components
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

    public var name: String {
        position.name
    }

    public var hasBalance: Bool {
        guard let vaultBalance = position.vaultBalanceValue,
              let balance = Double(vaultBalance) else {
            return false
        }
        return balance > 0
    }

    public var vaultBalance: BigInt? {
        guard let vaultBalanceStr = position.vaultBalanceValue else {
            return nil
        }
        return BigInt(vaultBalanceStr)
    }

    public var vaultBalanceFormatted: String {
        guard let vaultBalance = position.vaultBalanceValue,
              let balance = Double(vaultBalance) else {
            return "0"
        }
        let divisor = pow(10.0, Double(decimals))
        return String(format: "%.6f", balance / divisor)
    }

    public var assetBalanceFormatted: String {
        guard let assetBalance = position.assetBalanceValue,
              let balance = Double(assetBalance) else {
            return "0"
        }
        let divisor = pow(10.0, Double(decimals))
        return String(format: "%.2f", balance / divisor)
    }

    public var apyText: String {
        guard let apy = position.apy else {
            return "--"
        }
        return String(format: "%.2f%%", apy * 100)
    }

    public var rewardsFormatted: String? {
        guard let rewardsStr = position.rewards,
              let rewards = Double(rewardsStr),
              rewards > 0 else {
            return nil
        }
        let divisor = pow(10.0, Double(decimals))
        return String(format: "%.2f", rewards / divisor)
    }

    public var providerName: String {
        switch position.provider {
        case .yo:
            return "Yo"
        }
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
        do {
            let position = try await yieldService.positions(
                provider: .yo,
                asset: input.asset.id,
                walletAddress: walletAddress
            )

            let positionViewModel = YieldPositionViewModel(
                position: position,
                decimals: Int(input.asset.decimals)
            )
            let opportunity = YieldOpportunityViewModel(position: position)
            state = .loaded([opportunity], positionViewModel)
        } catch {
            state = .error(error)
        }
    }

    public func onSelectOpportunity(_ opportunity: YieldOpportunityViewModel) {
        let yieldData = YieldData(
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
        let yieldData = YieldData(
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
