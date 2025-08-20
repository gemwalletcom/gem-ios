// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Localization
import Primitives
import Preferences
import PreferencesTestKit
import PrimitivesComponents
import Style

@testable import Transactions
@testable import Store

@MainActor
struct TransactionDetailViewModelTests {

    @Test
    func participantFieldTransfer() {
        let incomingTransfer = TransactionDetailViewModel.mock(type: .transfer, direction: .incoming)
        let outgoingTransfer = TransactionDetailViewModel.mock(type: .transfer, direction: .outgoing)
        let incomingNFT = TransactionDetailViewModel.mock(type: .transferNFT, direction: .incoming)
        let outgoingNFT = TransactionDetailViewModel.mock(type: .transferNFT, direction: .outgoing)
        
        #expect(incomingTransfer.participantField == Localized.Transaction.sender)
        #expect(outgoingTransfer.participantField == Localized.Transaction.recipient)
        #expect(incomingNFT.participantField == Localized.Transaction.sender)
        #expect(outgoingNFT.participantField == Localized.Transaction.recipient)
    }

    @Test
    func participantFieldContract() {
        #expect(TransactionDetailViewModel.mock(type: .tokenApproval).participantField == Localized.Asset.contract)
        #expect(TransactionDetailViewModel.mock(type: .smartContractCall).participantField == Localized.Asset.contract)
    }

    @Test
    func participantFieldStakeDelegate() {
        #expect(TransactionDetailViewModel.mock(type: .stakeDelegate).participantField == Localized.Stake.validator)
    }

    @Test
    func participantFieldIsNilForOthers() {
        let nilTypes: [TransactionType] = [
            .swap, .stakeUndelegate, .stakeRedelegate, 
            .stakeRewards, .stakeWithdraw, .assetActivation
        ]
        for type in nilTypes {
            #expect(TransactionDetailViewModel.mock(type: type).participantField == nil)
        }
    }

    @Test
    func participantReturnsValue() {
        let participantTypes: [TransactionType] = [
            .transfer, .transferNFT, .tokenApproval, 
            .smartContractCall, .stakeDelegate
        ]

        for type in participantTypes {
            let model = TransactionDetailViewModel.mock(type: type)
            #expect(model.participant == "participant_address")
        }
    }

    @Test
    func participantIsNilForOthers() {
        let nilTypes: [TransactionType] = [
            .swap, .stakeUndelegate, .stakeRedelegate, 
            .stakeRewards, .stakeWithdraw, .assetActivation
        ]
        for type in nilTypes {
            #expect(TransactionDetailViewModel.mock(type: type).participant == nil)
        }
    }

    @Test
    func memoField() {
        let allTypes: [TransactionType] = [
            .transfer, .transferNFT, .swap, .tokenApproval, .assetActivation,
            .smartContractCall, .stakeRewards, .stakeWithdraw, .stakeDelegate,
            .stakeUndelegate, .stakeRedelegate
        ]
        for type in allTypes {
            #expect(TransactionDetailViewModel.mock(type: type, memo: nil).memo == nil)
            #expect(TransactionDetailViewModel.mock(type: type, memo: "").memo == "")
            #expect(TransactionDetailViewModel.mock(type: type, memo: "Test memo").memo == "Test memo")
        }
    }

    @Test
    func statusListItemStyle() {
        let confirmed = TransactionDetailViewModel.mock(state: .confirmed)
        let pending = TransactionDetailViewModel.mock(state: .pending)
        let failed = TransactionDetailViewModel.mock(state: .failed)
        let reverted = TransactionDetailViewModel.mock(state: .reverted)
        
        let confirmedModel = confirmed.model(for: .status) as? StatusListItemViewModel
        let pendingModel = pending.model(for: .status) as? StatusListItemViewModel
        let failedModel = failed.model(for: .status) as? StatusListItemViewModel
        let revertedModel = reverted.model(for: .status) as? StatusListItemViewModel
        
        #expect(confirmedModel?.style.color == Colors.green)
        #expect(pendingModel?.style.color == Colors.orange)
        #expect(failedModel?.style.color == Colors.red)
        #expect(revertedModel?.style.color == Colors.red)
    }
}

extension TransactionDetailViewModel {
    static func mock(
        type: TransactionType = .transfer,
        state: TransactionState = .confirmed,
        direction: TransactionDirection = .outgoing,
        participant: String = "participant_address",
        memo: String? = nil
    ) -> TransactionDetailViewModel {
        TransactionDetailViewModel(
            transaction: TransactionExtended.mock(
                transaction: Transaction.mock(
                    type: type, state: state, direction: direction, 
                    to: participant, memo: memo
                )
            ),
            walletId: "test_wallet_id",
            preferences: Preferences.standard
        )
    }
}
