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
        let values: [(type: HeaderButtonType, isDisabled: Bool, isShown: Bool)] = [
            (HeaderButtonType.send, walletModel.isButtonDisabled(type: .send), true),
            (HeaderButtonType.receive, walletModel.isButtonDisabled(type: .receive), true),
            (HeaderButtonType.buy, walletModel.isButtonDisabled(type: .buy), assetDataModel.isBuyEnabled),
            (HeaderButtonType.swap, walletModel.isButtonDisabled(type: .swap), assetDataModel.isSwapEnabled),
        ]
        return values.compactMap {
            if $0.isShown {
                return HeaderButton(type: $0.type, isDisabled: $0.isDisabled)
            }
            return .none
        }
    }
}
