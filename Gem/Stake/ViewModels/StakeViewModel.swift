// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Blockchain
import Store
import Components
import BigInt
import Gemstone

struct StakeViewModel {
    let wallet: Wallet
    let chain: Chain
    let service: StakeService
    
    private let formatter = ValueFormatter(style: .medium)
    private let recommendedValidators = StakeRecommendedValidators()
    
    private static let lockTimeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day]
        formatter.unitsStyle = .full
        return formatter
    }()
    
    static let stakeMemo = "Stake via Gem Wallet"
    
    var title: String {
        return Localized.Transfer.Stake.title //String(format: "%@ (%@)", chain.asset.name, chain.asset.symbol)
    }
    
    var request: StakeDelegationsRequest {
        return StakeDelegationsRequest(walletId: wallet.id, assetId: chain.id)
    }
    
    var stakeAprText: String {
        let apr = (try? service.stakeApr(assetId: chain.assetId)) ?? 0
        if apr > 0 {
            return CurrencyFormatter(type: .percentSignLess).string(apr)
        }
        return .empty
    }
    
    private var lockTime: TimeInterval {
        Double(Config().getStakeLocktime(chain: chain.rawValue))
    }
    
    var lockTimeText: String {
        let now = Date.now
        let date = now.addingTimeInterval(lockTime)
        return Self.lockTimeFormatter.string(from: now, to: date) ?? .empty
    }

    private var minAmount: BigInt {
        BigInt(Config().getMinStakeAmount(chain: chain.rawValue))
    }

    var minAmountText: String? {
        let amount = minAmount
        if amount == 0 {
            return nil
        }
        return formatter.string(amount, decimals: Int(asset.decimals), currency: asset.symbol)
    }

    private var asset: Asset {
        chain.asset
    }
    
    var assetText: String {
        AssetViewModel(asset: chain.asset).title
    }
    
    var recommendedCurrentValidator: DelegationValidator? {
        guard let validatorId = recommendedValidators.randomValidatorId(chain: chain) else {
            return .none
        }
        return try? service.store.getValidator(assetId: asset.id, validatorId: validatorId)
    }
    
    func value(delegations: [Delegation]) -> BigInt {
        return delegations.map { $0.base.rewardsValue }.reduce(0, +)
    }
    
    func showClaimRewards(delegations: [Delegation]) -> Bool {
        value(delegations: delegations) > 0 && ![Chain.solana, Chain.sui].contains(chain)
    }
    
    func rewards(delegations: [Delegation]) -> String {
        formatter.string(value(delegations: delegations), decimals: asset.decimals.asInt, currency: asset.symbol)
    }
    
    func stakeRecipientData() throws -> AmountRecipientData {
        AmountRecipientData(
            type: .stake(validators: try service.getActiveValidators(assetId: chain.assetId)),
            data: RecipientData(
                asset: chain.asset,
                recipient: Recipient(name: "", address: "", memo: Self.stakeMemo)
            )
        )
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
    
    func fetch() async {
        do {
            let acccount = try wallet.account(for: chain)
            try await service.update(walletId: wallet.id, chain: chain, address: acccount.address)
        } catch {
            NSLog("stake fetch error: \(error)")
        }
    }
    
}

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
