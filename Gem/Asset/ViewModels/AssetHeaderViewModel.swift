// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives

struct AssetHeaderViewModel {
    let assetDataModel: AssetDataViewModel
    let walletModel: WalletViewModel
    let bannersViewModel: HeaderBannersViewModel
}

extension AssetHeaderViewModel: HeaderViewModel {
    var showBalancePrivacy: Bool { false }

    var isWatchWallet: Bool {
        walletModel.wallet.type == .view
    }
    
    var assetImage: AssetImage? {
        assetDataModel.assetImage
    }
    
    var title: String {
        assetDataModel.totalBalanceTextWithSymbol
    }
    
    var subtitle: String? {
        if assetDataModel.fiatBalanceText.isEmpty {
            return .none
        }
        return assetDataModel.fiatBalanceText
    }

    var buttons: [HeaderButton] {
        let values: [(type: HeaderButtonType, isShown: Bool, isEnabled: Bool)] = [
            (HeaderButtonType.send, true, bannersViewModel.isButtonsEnabled),
            (HeaderButtonType.receive, true, bannersViewModel.isButtonsEnabled),
            (HeaderButtonType.buy, assetDataModel.isBuyEnabled, bannersViewModel.isButtonsEnabled),
            (HeaderButtonType.sell, assetDataModel.isSellEnabled && assetDataModel.hasAvailableBalance, bannersViewModel.isButtonsEnabled),
            (HeaderButtonType.swap, assetDataModel.isSwapEnabled, bannersViewModel.isButtonsEnabled),
        ]
        return values.compactMap {
            if $0.isShown {
                return HeaderButton(type: $0.type, isEnabled: $0.isEnabled)
            }
            return .none
        }
    }
}
