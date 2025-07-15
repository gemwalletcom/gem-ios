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

struct TransactionDetailViewModelTests {

    @Test
    func participantField_transfer() {
        #expect(TransactionDetailViewModel.mock(type: .transfer, direction: .incoming).participantField == Localized.Transaction.sender)
        #expect(TransactionDetailViewModel.mock(type: .transfer, direction: .outgoing).participantField == Localized.Transaction.recipient)
        #expect(TransactionDetailViewModel.mock(type: .transferNFT, direction: .incoming).participantField == Localized.Transaction.sender)
        #expect(TransactionDetailViewModel.mock(type: .transferNFT, direction: .outgoing).participantField == Localized.Transaction.recipient)
    }

    @Test
    func participantField_contract() {
        #expect(TransactionDetailViewModel.mock(type: .tokenApproval).participantField == Localized.Asset.contract)
        #expect(TransactionDetailViewModel.mock(type: .smartContractCall).participantField == Localized.Asset.contract)
    }

    @Test
    func participantField_stakeDelegate() {
        #expect(TransactionDetailViewModel.mock(type: .stakeDelegate).participantField == Localized.Stake.validator)
    }

    @Test
    func participantField_isNilForOthers() {
        let nilTypes: [TransactionType] = [.swap, .stakeUndelegate, .stakeRedelegate, .stakeRewards, .stakeWithdraw, .assetActivation]
        for type in nilTypes {
            #expect(TransactionDetailViewModel.mock(type: type).participantField == nil)
        }
    }

    @Test
    func participant_returnsValue() {
        let participantTypes: [TransactionType] = [.transfer, .transferNFT, .tokenApproval, .smartContractCall, .stakeDelegate]

        for type in participantTypes {
            #expect(TransactionDetailViewModel.mock(type: type).participant == "participant_address")
        }
    }

    @Test
    func participant_isNilForOthers() {
        let nilTypes: [TransactionType] = [.swap, .stakeUndelegate, .stakeRedelegate, .stakeRewards, .stakeWithdraw, .assetActivation]
        for type in nilTypes {
            #expect(TransactionDetailViewModel.mock(type: type).participant == nil)
        }
    }

    @Test
    func showMemoField() {
        let allTypes: [TransactionType] = [.transfer, .transferNFT, .swap, .tokenApproval, .assetActivation, .smartContractCall, .stakeRewards, .stakeWithdraw, .stakeDelegate, .stakeUndelegate, .stakeRedelegate]
        for type in allTypes {
            #expect(TransactionDetailViewModel.mock(type: type, memo: nil).showMemoField == false)
            #expect(TransactionDetailViewModel.mock(type: type, memo: "Test memo").showMemoField == true)
        }
    }

    @Test
    func statusTextStyle() {
        #expect(TransactionDetailViewModel.mock(state: .confirmed).statusTextStyle.color == Colors.green)
        #expect(TransactionDetailViewModel.mock(state: .pending).statusTextStyle.color == Colors.orange)
        #expect(TransactionDetailViewModel.mock(state: .failed).statusTextStyle.color == Colors.red)
        #expect(TransactionDetailViewModel.mock(state: .reverted).statusTextStyle.color == Colors.red)
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
        TransactionDetailViewModel(model: TransactionViewModel.mock(type: type, state: state, direction: direction, participant: participant, memo: memo))
    }
}
