// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import PrimitivesComponents
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
        guard showMemo else { return .empty }
        return .memo(MemoViewModel(memo: recipientData.recipient.memo).listItemModel)
    }
}

// MARK: - Private

extension ConfirmTransferMemoViewModel {
    private var showMemo: Bool {
        switch type {
        case .transfer, .deposit, .withdrawal: type.chain.isMemoSupported
        case .transferNft, .swap, .tokenApprove, .generic, .account, .stake, .perpetual: false
        }
    }
}
