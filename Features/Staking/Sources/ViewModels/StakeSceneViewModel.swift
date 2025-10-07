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
public final class StakeSceneViewModel {
    private let stakeService: any StakeServiceable

    private var delegatitonsState: StateViewType<Bool> = .loading
    private let chain: StakeChain

    private let formatter = ValueFormatter(style: .medium)
    private let recommendedValidators = StakeRecommendedValidators()

    public let wallet: Wallet
    public var request: StakeDelegationsRequest
    public var delegations: [Delegation] = []

    public var assetRequest: AssetRequest
    public var assetData: AssetData = .empty

    public var isPresentingInfoSheet: InfoSheetType? = .none

    public init(
        wallet: Wallet,
        chain: StakeChain,
        stakeService: any StakeServiceable
    ) {
        self.wallet = wallet
        self.chain = chain
        self.stakeService = stakeService
        self.request = StakeDelegationsRequest(walletId: wallet.id, assetId: chain.chain.id)
        self.assetRequest = AssetRequest(walletId: wallet.id, assetId: chain.chain.assetId)
    }

    public var stakeInfoUrl: URL {
        Docs.url(.staking(stakeChain.map()))
    }

    var title: String { Localized.Transfer.Stake.title }

    var stakeTitle: String { Localized.Transfer.Stake.title }
    var claimRewardsTitle: String { Localized.Transfer.ClaimRewards.title }
    var assetTitle: String { assetModel.title }

    var stakeAprTitle: String { Localized.Stake.apr("") }
    var stakeAprValue: String {
        let apr = (try? stakeService.stakeApr(assetId: chain.chain.assetId)) ?? 0
        guard apr > 0 else {
            return .empty
        }
        return CurrencyFormatter.percentSignLess.string(apr)
    }

    var resourcesTitle: String { Localized.Asset.resources }

    var energyTitle: String { ResourceViewModel(resource: .energy).title }
    var energyText: String { balanceModel.energyText }

    var bandwidthTitle: String { ResourceViewModel(resource: .bandwidth).title }
    var bandwidthText: String { balanceModel.bandwidthText }

    var freezeTitle: String { Localized.Transfer.Freeze.title }
    var unfreezeTitle: String { Localized.Transfer.Unfreeze.title }


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
        guard let validatorId = recommendedValidators.randomValidatorId(chain: chain.chain) else { return .none }
        return try? stakeService.getValidator(assetId: asset.id, validatorId: validatorId)
    }

    var emptyContentModel: EmptyContentTypeViewModel {
        EmptyContentTypeViewModel(type: .stake(symbol: assetModel.symbol))
    }

    var delegationsState: StateViewType<[StakeDelegationViewModel]> {
        let delegationModels = delegations.map { StakeDelegationViewModel(delegation: $0) }
        
        switch delegatitonsState {
        case .noData: return .noData
        case .loading: return delegationModels.isEmpty ? .loading : .data(delegationModels)
        case .data: return delegationModels.isEmpty ? .noData : .data(delegationModels)
        case .error(let error): return .error(error)
        }
    }
    
    var claimRewardsText: String {
        formatter.string(rewardsValue, decimals: asset.decimals.asInt, currency: asset.symbol)
    }

    var canClaimRewards: Bool {
        chain.supportClaimRewards && rewardsValue > 0
    }
    
    var claimRewardsDestination: any Hashable {
        let validators = delegations
            .filter { $0.base.rewardsValue > 0 }
            .map { $0.validator }

        return TransferData(
            type: .stake(chain.chain.asset, .rewards(validators)),
            recipientData: RecipientData(
                recipient: Recipient(name: .none, address: "", memo: .none),
                amount: .none
            ),
            value: rewardsValue
        )
    }

    var stakeDestination: any Hashable {
        destination(
            type: .stake(
                validators: (try? stakeService.getActiveValidators(assetId: chain.chain.assetId)) ?? [],
                recommendedValidator: recommendedCurrentValidator
            )
        )
    }

    var freezeDestination: any Hashable {
        destination(
            type: .freeze(
                data: FreezeData(
                    freezeType: .freeze,
                    resource: .bandwidth
                )
            )
        )
    }

    var unfreezeDestination: any Hashable {
        destination(
            type: .freeze(
                data: FreezeData(
                    freezeType: .unfreeze,
                    resource: .bandwidth
                )
            )
        )
    }

    var showFreeze: Bool { chain == .tron }
    var showUnfreeze: Bool { balanceModel.hasStakingResources }
    var showStake: Bool {
        if showFreeze {
            return balanceModel.hasStakingResources
        }
        return true
    }

    var showTronResources: Bool {
        balanceModel.hasStakingResources
    }
}

// MARK: - Business Logic

extension StakeSceneViewModel {
    func fetch() async {
        delegatitonsState = .loading
        do {
            let acccount = try wallet.account(for: chain.chain)
            try await stakeService.update(walletId: wallet.id, chain: chain.chain, address: acccount.address)
            delegatitonsState = .data(true)
        } catch {
            print("Stake scene fetch error: \(error)")
            delegatitonsState = .error(error)
        }
    }
    
    func onLockTimeInfo() {
        isPresentingInfoSheet = lockTimeInfoSheet
    }
}

// MARK: - Private

extension StakeSceneViewModel {
    private static let lockTimeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day]
        formatter.unitsStyle = .full
        return formatter
    }()

    private var lockTime: TimeInterval {
        Double(StakeConfig.config(chain: chain).timeLock)
    }

    private var minAmount: BigInt {
        BigInt(StakeConfig.config(chain: chain).minAmount)
    }

    private var assetModel: AssetViewModel {
        AssetViewModel(asset: asset)
    }

    private var asset: Asset {
        chain.chain.asset
    }

    private var balanceModel: BalanceViewModel {
        BalanceViewModel(asset: asset, balance: assetData.balance, formatter: formatter)
    }

    private var rewardsValue: BigInt {
        delegations.map { $0.base.rewardsValue }.reduce(0, +)
    }

    private func destination(type: AmountType) -> any Hashable {
        AmountInput(
            type: type,
            asset: asset
        )
    }
}
