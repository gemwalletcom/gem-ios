// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives

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

//struct ActivityView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityView(model: TransactionExtendedViewModel(transaction: .main, asset: .main, transactionModel: TransactionViewModel(transaction: .main)))
//    }
//}
