// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives

struct AssetHeaderViewModel {
    let assetDataModel: AssetDataViewModel
    let walletModel: WalletViewModel
}

extension AssetHeaderViewModel: HeaderViewModel {
    
    var isWatchWallet: Bool {
        walletModel.wallet.type == .view
    }
    
    var assetImage: AssetImage? {
        return assetDataModel.assetImage
    }
    
    var title: String {
        return assetDataModel.totalBalanceTextWithSymbol
    }
    
    var subtitle: String? {
        if assetDataModel.fiatBalanceText.isEmpty {
            return .none
        }
        return assetDataModel.fiatBalanceText
    }
    
    var buttons: [HeaderButton] {
        let values: [(type: HeaderButtonType, isShown: Bool)] = [
            (HeaderButtonType.send, true),
            (HeaderButtonType.receive, true),
            (HeaderButtonType.buy, assetDataModel.isBuyEnabled),
            (HeaderButtonType.swap, assetDataModel.isSwapEnabled),
        ]
        return values.compactMap {
            if $0.isShown {
                return HeaderButton(type: $0.type)
            }
            return .none
        }
    }
}
