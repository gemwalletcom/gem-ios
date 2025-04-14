// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Components
import GemstonePrimitives

@Observable
final class SecurityReminderCreateWalletViewModel: SecurityReminderViewModel {
    let onNext: () -> Void
    
    init(onNext: @escaping () -> Void) {
        self.onNext = onNext
    }
    
    var title: String = Localized.Wallet.New.title
    var message: String = Localized.Onboarding.Security.CreateWallet.message
    var checkMarkTitle: String = Localized.Onboarding.Security.CreateWallet.checkmartTitle
    var buttonTitle: String = Localized.Common.continue
    let items: [SecurityReminderItem] = SecurityReminderItem.createWallet
    var docsUrl: URL { Docs.url(.whatIsSecretPhrase) }
    
    var isConfirmed = false
    
    var buttonState: StateViewType<Bool> {
        isConfirmed ? .data(true) : .noData
    }
}
