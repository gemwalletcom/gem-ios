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
struct TransactionSceneViewModelTests {

    @Test
    func participantFieldTransfer() {
        #expect(TransactionSceneViewModel.mock(type: .transfer, direction: .incoming).participantField == Localized.Transaction.sender)
        #expect(TransactionSceneViewModel.mock(type: .transfer, direction: .outgoing).participantField == Localized.Transaction.recipient)
        #expect(TransactionSceneViewModel.mock(type: .transferNFT, direction: .incoming).participantField == Localized.Transaction.sender)
        #expect(TransactionSceneViewModel.mock(type: .transferNFT, direction: .outgoing).participantField == Localized.Transaction.recipient)
    }

    @Test
    func participantFieldContract() {
        #expect(TransactionSceneViewModel.mock(type: .tokenApproval).participantField == Localized.Asset.contract)
        #expect(TransactionSceneViewModel.mock(type: .smartContractCall).participantField == Localized.Asset.contract)
    }

    @Test
    func participantFieldStakeDelegate() {
        #expect(TransactionSceneViewModel.mock(type: .stakeDelegate).participantField == Localized.Stake.validator)
    }

    @Test
    func participantFieldIsNilForOthers() {
        let nilTypes: [TransactionType] = [.swap, .stakeUndelegate, .stakeRedelegate, .stakeRewards, .stakeWithdraw, .assetActivation]
        for type in nilTypes {
            #expect(TransactionSceneViewModel.mock(type: type).participantField == nil)
        }
    }

    @Test
    func participantReturnsValue() {
        let participantTypes: [TransactionType] = [.transfer, .transferNFT, .tokenApproval, .smartContractCall, .stakeDelegate]

        for type in participantTypes {
            #expect(TransactionSceneViewModel.mock(type: type).participant == "participant_address")
        }
    }

    @Test
    func participantIsNilForOthers() {
        let nilTypes: [TransactionType] = [.swap, .stakeUndelegate, .stakeRedelegate, .stakeRewards, .stakeWithdraw, .assetActivation]
        for type in nilTypes {
            #expect(TransactionSceneViewModel.mock(type: type).participant == nil)
        }
    }

    @Test
    func showMemoField() {
        let allTypes: [TransactionType] = [.transfer, .transferNFT, .swap, .tokenApproval, .assetActivation, .smartContractCall, .stakeRewards, .stakeWithdraw, .stakeDelegate, .stakeUndelegate, .stakeRedelegate]
        for type in allTypes {
            #expect(TransactionSceneViewModel.mock(type: type, memo: nil).showMemoField == false)
            #expect(TransactionSceneViewModel.mock(type: type, memo: "").showMemoField == false)
            #expect(TransactionSceneViewModel.mock(type: type, memo: "Test memo").showMemoField == true)
        }
    }

    @Test
    func statusTextStyle() {
        #expect(TransactionSceneViewModel.mock(state: .confirmed).statusTextStyle.color == Colors.green)
        #expect(TransactionSceneViewModel.mock(state: .pending).statusTextStyle.color == Colors.orange)
        #expect(TransactionSceneViewModel.mock(state: .failed).statusTextStyle.color == Colors.red)
        #expect(TransactionSceneViewModel.mock(state: .reverted).statusTextStyle.color == Colors.red)
    }
}

extension TransactionSceneViewModel {
    static func mock(
        type: TransactionType = .transfer,
        state: TransactionState = .confirmed,
        direction: TransactionDirection = .outgoing,
        participant: String = "participant_address",
        memo: String? = nil
    ) -> TransactionSceneViewModel {
        TransactionSceneViewModel(
            transaction: TransactionExtended.mock(
                transaction: Transaction.mock(type: type, state: state, direction: direction, to: participant, memo: memo)
            ),
            walletId: "test_wallet_id",
            preferences: Preferences.standard
        )
    }
}
