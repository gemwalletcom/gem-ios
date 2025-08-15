// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import PrimitivesComponents
import Components

struct ValidatorHeaderViewModel: HeaderViewModel {
    
    let model: StakeDelegationViewModel
    
    let isWatchWallet: Bool = false
    let buttons: [HeaderButton] = []
    let allowHiddenBalance: Bool = false
    
    var assetImage: AssetImage? {
        model.validatorImage
    }
    
    var title: String {
        model.balanceText
    }
    
    var subtitle: String? {
        model.fiatValueText
    }
}
