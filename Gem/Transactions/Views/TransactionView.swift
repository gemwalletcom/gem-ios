// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Style

struct TransactionView: View {
    let model: TransactionViewModel

    init(model: TransactionViewModel) {
        self.model = model
    }

    var body: some View {
        HStack {
            AssetImageView(assetImage: model.assetImage)
            ListItemView(
                title: model.title,
                titleStyle: model.titleTextStyle,
                titleTag: model.titleTag,
                titleTagStyle: model.titleTagStyle,
                titleTagType: model.titleTagType,
                titleExtra: model.titleExtra,
                titleStyleExtra: model.titleTextStyleExtra,
                subtitle: model.subtitle,
                subtitleStyle: model.subtitleTextStyle,
                subtitleExtra: model.subtitleExtra,
                subtitleStyleExtra: model.subtitleExtraStyle
            )
        }
        .contextMenu {
            ContextMenuViewURL(title: model.viewOnTransactionExplorerText, url: model.transactionExplorerUrl, image: SystemImage.globe)
        }
    }
}

// MARK: - Previews

#Preview {
    let pendingTransactionMock = Transaction(
        id: "smartchain_0xe5fb66cef0fb71fa75e0245484a40d17952cf46053724c6ac61209bf307d6e56",
        hash: "0xe5fb66cef0fb71fa75e0245484a40d17952cf46053724c6ac61209bf307d6e56",
        assetId: .binance,
        from: "0x92abCE21234D71EC443E679f3a1feAFD3Fc830fB",
        to: "0x8d7460E51bCf4eD26877cb77E56f3ce7E9f5EB8F",
        contract: nil,
        type: .transfer,
        state: .pending,
        blockNumber: "39348339",
        sequence: "1",
        fee: "21000000000000",
        feeAssetId: .binance,
        value: "100000000000000",
        memo: nil,
        direction: .outgoing,
        utxoInputs: [],
        utxoOutputs: [],
        metadata: nil,
        createdAt: Date()
    )
    let pendingTransactionExtendedMock = TransactionExtended(
        transaction: pendingTransactionMock,
        asset: .bitcoin,
        feeAsset: .bitcoin,
        price: nil,
        feePrice: nil,
        assets: []
    )

    let transactionVMMock = TransactionViewModel(transaction: pendingTransactionExtendedMock, formatter: .short)

    return TransactionView(model: transactionVMMock)
}
