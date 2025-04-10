// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Components

@Observable
final class SecurityReminderCreateWalletViewModel: SecurityReminderViewModel {
    var title: String = "Security Reminder"
    var message: String = "Hate sharing 🍕 slices? Follow this unless you want to share your crypto as well"
    var checkMarkTitle: String = "In the next screen we will show you a Secret Phrase"
    var buttonTitle: String = Localized.Common.continue
    let items: [SecurityReminderItem] = SecurityReminderItem.createWallet
    
    var isConfirmed = false
    
    var buttonState: StateViewType<Bool> {
        isConfirmed ? .data(true) : .noData
    }
}
