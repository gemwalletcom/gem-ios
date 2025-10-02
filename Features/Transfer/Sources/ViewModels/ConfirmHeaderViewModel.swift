// Copyright (c). Gem Wallet. All rights reserved.

import Components
import PrimitivesComponents
import Primitives

struct ConfirmHeaderViewModel {
    private let inputModel: TransactionInputViewModel?
    private let metadata: TransferDataMetadata?
    private let data: TransferData

    init(inputModel: TransactionInputViewModel?, metadata: TransferDataMetadata?, data: TransferData) {
        self.inputModel = inputModel
        self.metadata = metadata
        self.data = data
    }
}

// MARK: - ItemModelProvidable

extension ConfirmHeaderViewModel: ItemModelProvidable {
    var itemModel: ConfirmTransferItemModel {
        .header(
            TransactionHeaderItemModel(
                headerType: headerType,
                showClearHeader: showClearHeader
            )
        )
    }
}

// MARK: - Private

extension ConfirmHeaderViewModel {
    private var headerType: TransactionHeaderType {
        guard let inputModel else {
            return TransactionInputViewModel(data: data, transactionData: nil, metaData: metadata, transferAmount: nil).headerType
        }
        return inputModel.headerType
    }

    private var showClearHeader: Bool {
        switch headerType {
        case .amount, .nft: true
        case .swap: false
        }
    }
}
