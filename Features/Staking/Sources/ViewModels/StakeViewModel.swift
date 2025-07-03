// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import Components
import BigInt
import GemstonePrimitives
import SwiftUI
import Localization
import StakeService
import InfoSheet
import PrimitivesComponents
import Formatters

@MainActor
@Observable
public final class StakeViewModel {
    private let wallet: Wallet

    private var delegatitonsState: StateViewType<Bool> = .loading
    private let chain: Chain
    private let stakeService: any StakeServiceable

    private let formatter = ValueFormatter(style: .medium)
    private let recommendedValidators = StakeRecommendedValidators()

    let onTransferAction: TransferDataAction
    let onAmountInputAction: AmountInputAction

    public init(
        wallet: Wallet,
        chain: Chain,
        stakeService: any StakeServiceable,
        onTransferAction: TransferDataAction,
        onAmountInputAction: AmountInputAction
    ) {
        self.wallet = wallet
        self.chain = chain
        self.stakeService = stakeService
        self.onTransferAction = onTransferAction
        self.onAmountInputAction = onAmountInputAction
    }

    var title: String { Localized.Transfer.Stake.title }

    var request: StakeDelegationsRequest { StakeDelegationsRequest(walletId: wallet.id, assetId: chain.id) }

    var stakeTitle: String { Localized.Transfer.Stake.title }
    var claimRewardsTitle: String { Localized.Transfer.ClaimRewards.title }
    var assetTitle: String { assetModel.title }

    var stakeAprTitle: String { Localized.Stake.apr("") }
    var stakeAprValue: String {
        let apr = (try? stakeService.stakeApr(assetId: chain.assetId)) ?? 0
        guard apr > 0 else {
            return .empty
        }
        return CurrencyFormatter(type: .percentSignLess).string(apr)
    }

    var lockTimeTitle: String { Localized.Stake.lockTime }
    var lockTimeValue: String {
        let now = Date.now
        let date = now.addingTimeInterval(lockTime)
        return Self.lockTimeFormatter.string(from: now, to: date) ?? .empty
    }
    var lockTimeInfoSheet: InfoSheetType {
        InfoSheetType.stakeLockTime(assetModel.assetImage.placeholder)
    }

    var minAmountTitle: String { Localized.Stake.minimumAmount }
    var minAmountValue: String? {
        guard minAmount != 0 else { return .none }
        return formatter.string(minAmount, decimals: Int(asset.decimals), currency: asset.symbol)
    }

    var delegationsErrorTitle: String { Localized.Errors.errorOccured }
    var delegationsRetryTitle: String { Localized.Common.tryAgain }
    var emptyDelegationsTitle: String { Localized.Stake.noActiveStaking }

    var showManage: Bool {
        !wallet.isViewOnly
    }
    
    var recommendedCurrentValidator: DelegationValidator? {
        guard let validatorId = recommendedValidators.randomValidatorId(chain: chain) else { return .none }
        return try? stakeService.getValidator(assetId: asset.id, validatorId: validatorId)
    }

    var emptyContentModel: EmptyContentTypeViewModel {
        EmptyContentTypeViewModel(type: .stake(symbol: assetModel.symbol))
    }

    func stakeDelegateionState(delegationModels: [StakeDelegationViewModel]) -> StateViewType<[StakeDelegationViewModel]> {
        switch delegatitonsState {
        case .noData: return .noData
        case .loading: return delegationModels.isEmpty ? .loading : .data(delegationModels)
        case .data: return delegationModels.isEmpty ? .noData : .data(delegationModels)
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
                recipient: Recipient(name: .none, address: "", memo: .none),
                amount: .none
            ),
            value: value,
            canChangeValue: false,
            ignoreValueCheck: true
        )
    }

    func stakeRecipientData() throws -> AmountInput {
        AmountInput(
            type: .stake(
                validators: try stakeService.getActiveValidators(assetId: chain.assetId),
                recommendedValidator: recommendedCurrentValidator
            ),
            asset: chain.asset
        )
    }
}

// MARK: - Business Logic

extension StakeViewModel {
    func fetch() async {
        delegatitonsState = .loading
        do {
            let acccount = try wallet.account(for: chain)
            try await stakeService.update(walletId: wallet.id, chain: chain, address: acccount.address)
            delegatitonsState = .data(true)
        } catch {
            print("Stake scene fetch error: \(error)")
            delegatitonsState = .error(error)
        }
    }

    func onSelectStake() {
        if let value = try? stakeRecipientData() {
            onAmountInputAction?(value)
        }
    }

    func onSelectDelegations(delegations: [Delegation]) {
        let delegations = delegations.filter { $0.base.rewardsValue > 0 }
        let transferData = claimRewardsTransferData(delegations: delegations)
        onTransferAction?(transferData)
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

    private var assetModel: AssetViewModel {
        AssetViewModel(asset: chain.asset)
    }

    private var asset: Asset {
        chain.asset
    }

    private func value(delegations: [Delegation]) -> BigInt {
        delegations.map { $0.base.rewardsValue }.reduce(0, +)
    }
}

