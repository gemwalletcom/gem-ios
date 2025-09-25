// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Localization
import Components

struct ConfirmTransferMemoViewModel {
    private let type: TransferDataType
    private let recipientData: RecipientData

    init(type: TransferDataType, recipientData: RecipientData) {
        self.type = type
        self.recipientData = recipientData
    }
}

// MARK: - ItemModelProvidable

extension ConfirmTransferMemoViewModel: ItemModelProvidable {
    var itemModel: ConfirmTransferItemModel {
        guard shouldShowMemo else { return .empty }
        return .memo(
            .text(
                title: Localized.Transfer.memo,
                subtitle: formattedMemo
            )
        )
    }
}

// MARK: - Private

extension ConfirmTransferMemoViewModel {
    private var memo: String? { recipientData.recipient.memo }

    private var shouldShowMemo: Bool {
        switch type {
        case .transfer, .deposit, .withdrawal: type.chain.isMemoSupported
        case .transferNft, .swap, .tokenApprove, .generic, .account, .stake, .perpetual: false
        }
    }

    private var formattedMemo: String {
        let value = memo ?? ""
        return value.isEmpty ? "-" : value
    }
}

