// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Style
import Localization
import Primitives

public enum ParticipantType {
    case sender
    case recipient
    case validator
    case contract
}

public struct TransactionParticipantItemModel: ListItemViewable {
    private let type: ParticipantType
    private let account: SimpleAccount
    private let addressLink: BlockExplorerLink
    
    public init?(
        transaction: Transaction,
        participantAddress: String?,
        chain: Chain,
        addressName: String?,
        addressLink: BlockExplorerLink
    ) {
        guard let participantType = Self.getParticipantType(for: transaction),
              let address = participantAddress else {
            return nil
        }
        self.type = participantType
        self.account = SimpleAccount(
            name: addressName,
            chain: chain,
            address: address,
            assetImage: nil
        )
        self.addressLink = addressLink
    }
    
    private static func getParticipantType(for transaction: Transaction) -> ParticipantType? {
        switch transaction.type {
        case .transfer, .transferNFT:
            switch transaction.direction {
            case .incoming:
                .sender
            case .outgoing, .selfTransfer:
                .recipient
            }
        case .tokenApproval, .smartContractCall:
            .contract
        case .stakeDelegate:
            .validator
        case .swap,
             .stakeUndelegate,
             .stakeRedelegate,
             .stakeRewards,
             .stakeWithdraw,
             .assetActivation,
             .perpetualOpenPosition,
             .perpetualClosePosition:
            nil
        }
    }
    
    private var title: String {
        switch type {
        case .sender:
            Localized.Transaction.sender
        case .recipient:
            Localized.Transaction.recipient
        case .validator:
            Localized.Stake.validator
        case .contract:
            Localized.Asset.contract
        }
    }
    
    public var addressViewModel: AddressListItemViewModel {
        AddressListItemViewModel(
            title: title,
            account: account,
            mode: .nameOrAddress,
            addressLink: addressLink
        )
    }
    
    public var listItemModel: ListItemType {
        addressViewModel.listItemModel
    }
}