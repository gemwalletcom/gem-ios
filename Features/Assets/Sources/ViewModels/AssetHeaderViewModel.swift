// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import PrimitivesComponents

struct AssetHeaderViewModel: Sendable {
    let assetDataModel: AssetDataViewModel
    let walletModel: WalletViewModel
    let bannerEventsViewModel: HeaderBannerEventViewModel
}

extension AssetHeaderViewModel: HeaderViewModel {
    var allowHiddenBalance: Bool { false }

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
            (HeaderButtonType.send, true, bannerEventsViewModel.isButtonsEnabled),
            (HeaderButtonType.receive, true, bannerEventsViewModel.isButtonsEnabled),
            (HeaderButtonType.buy, assetDataModel.isBuyEnabled, bannerEventsViewModel.isButtonsEnabled),
            //(HeaderButtonType.sell, assetDataModel.isSellEnabled && assetDataModel.hasAvailableBalance, bannerEventsViewModel.isButtonsEnabled),
            (HeaderButtonType.swap, assetDataModel.isSwapEnabled, bannerEventsViewModel.isButtonsEnabled),
        ]
        return values.compactMap {
            if $0.isShown {
                return HeaderButton(type: $0.type, isEnabled: $0.isEnabled)
            }
            return .none
        }
    }
}
