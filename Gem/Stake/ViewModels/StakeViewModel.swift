// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Blockchain
import Store
import Components
import BigInt
import GemstonePrimitives

@Observable
class StakeViewModel {
    let wallet: Wallet

    var transferData: TransferData?
    var recipientData: AmountRecipientData?

    private var delegatitonsState: StateViewType<Bool> = .loading
    private let chain: Chain
    private let stakeService: StakeService

    private let formatter = ValueFormatter(style: .medium)
    private let recommendedValidators = StakeRecommendedValidators()

    init(wallet: Wallet, chain: Chain, stakeService: StakeService) {
        self.wallet = wallet
        self.chain = chain
        self.stakeService = stakeService
    }

    static let stakeMemo = Localized.Stake.viagem

    var title: String { Localized.Transfer.Stake.title }

    var request: StakeDelegationsRequest { StakeDelegationsRequest(walletId: wallet.id, assetId: chain.id) }

    var stakeTitle: String { Localized.Transfer.Stake.title }
    var claimRewardsTitle: String { Localized.Transfer.ClaimRewards.title }
    var assetTitle: String { AssetViewModel(asset: chain.asset).title }

    var stakeAprTitle: String { Localized.Stake.apr("") }
    var stakeAprValue: String {
        let apr = (try? stakeService.stakeApr(assetId: chain.assetId)) ?? 0
        guard apr > 0 else { return .empty}
        return CurrencyFormatter(type: .percentSignLess).string(apr)
    }

    var lockTimeTitle: String { Localized.Stake.lockTime }
    var lockTimeValue: String {
        let now = Date.now
        let date = now.addingTimeInterval(lockTime)
        return Self.lockTimeFormatter.string(from: now, to: date) ?? .empty
    }

    var minAmountTitle: String { Localized.Stake.minimumAmount }
    var minAmountValue: String? {
        guard minAmount != 0 else { return .none }
        return formatter.string(minAmount, decimals: Int(asset.decimals), currency: asset.symbol)
    }

    var delegationsErrorTitle: String { Localized.Errors.errorOccured }
    var delegationsRetryTitle: String { Localized.Common.tryAgain }
    var emptyDelegationsTitle: String { Localized.Stake.noActiveStaking }

    var recommendedCurrentValidator: DelegationValidator? {
        guard let validatorId = recommendedValidators.randomValidatorId(chain: chain) else { return .none }
        return try? stakeService.store.getValidator(assetId: asset.id, validatorId: validatorId)
    }

    func stakeDelegateionState(delegationModels: [StakeDelegationViewModel]) -> StateViewType<[StakeDelegationViewModel]> {
        switch delegatitonsState {
        case .noData: return .noData
        case .loading: return .loading
        case .loaded: return delegationModels.isEmpty ? .noData : .loaded(delegationModels)
        case .error(let error): return .error(error)
        }
    }
    
    func showClaimRewards(delegations: [Delegation]) -> Bool {
        value(delegations: delegations) > 0 && ![Chain.solana, Chain.sui].contains(chain)
    }
    
    func claimRewardsText(delegations: [Delegation]) -> String {
        formatter.string(value(delegations: delegations), decimals: asset.decimals.asInt, currency: asset.symbol)
    }

    func claimRewardsTransferData(delegations: [Delegation]) -> TransferData {
        let validators = delegations.map { $0.validator }
        let value = value(delegations: delegations)

        return TransferData(
            type: .stake(chain.asset, .rewards(validators: validators)),
            recipientData: RecipientData(
                asset: chain.asset,
                recipient: Recipient(name: .none, address: "", memo: StakeViewModel.stakeMemo)
            ),
            value: value
        )
    }

    func stakeRecipientData() throws -> AmountRecipientData {
        AmountRecipientData(
            type: .stake(validators: try stakeService.getActiveValidators(assetId: chain.assetId)),
            data: RecipientData(
                asset: chain.asset,
                recipient: Recipient(name: "", address: "", memo: Self.stakeMemo)
            )
        )
    }
}

// MARK: - Business Logic

extension StakeViewModel {
    func fetch() async {
        await MainActor.run { [self] in
            delegatitonsState = .loading
        }

        do {
            let acccount = try wallet.account(for: chain)
            try await stakeService.update(walletId: wallet.id, chain: chain, address: acccount.address)
            await MainActor.run { [self] in
                delegatitonsState = .loaded(true)
            }
        } catch {
            print("Stake scene fetch error: \(error)")
            await MainActor.run { [self] in
                delegatitonsState = .error(error)
            }
        }
    }
}

// MARK: - Private

extension StakeViewModel {
    private static let lockTimeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day]
        formatter.unitsStyle = .full
        return formatter
    }()

    private var lockTime: TimeInterval {
        Double(StakeConfig.config(chain: chain.stakeChain!).timeLock)
    }

    private var minAmount: BigInt {
        BigInt(StakeConfig.config(chain: chain.stakeChain!).minAmount)
    }

    private var asset: Asset {
        chain.asset
    }

    private func value(delegations: [Delegation]) -> BigInt {
        delegations.map { $0.base.rewardsValue }.reduce(0, +)
    }
}

// MARK: - Models extensions

extension DelegationState {
    public var title: String {
        switch self {
        case .active: Localized.Stake.active
        case .pending: Localized.Stake.pending
        case .undelegating: Localized.Stake.pending
        case .inactive: Localized.Stake.inactive
        case .activating: Localized.Stake.activating
        case .deactivating: Localized.Stake.deactivating
        case .awaitingWithdrawal: Localized.Stake.awaitingWithdrawal
        }
    }
}
